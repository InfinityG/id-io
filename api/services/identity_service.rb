require './api/services/signature_service'
require './api/services/cipher_service'
require './api/services/config_service'
require './api/services/token_service'
require './api/services/challenge_service'
require './api/services/trust_service'
require './api/utils/hash_generator'
require './api/errors/identity_error'
require 'base64'
require 'openssl'

class IdentityService
  include ErrorConstants::IdentityErrors
  include HashGenerator

  def initialize(signature_service = SignatureService, config_service = ConfigurationService,
                 token_service = TokenService, challenge_service = ChallengeService,
                 trust_service = TrustService, cipher_service = CipherService)
    @signature_service = signature_service.new
    @configuration_service = config_service.new
    @token_service = token_service.new
    @challenge_service = challenge_service.new
    @trust_service = trust_service.new
    @cipher_service = cipher_service.new
  end

  # if we've reached here then all is good - generate an auth response
  # RESPONSE (the "auth" field value is ENCRYPTED with a shared AES key)
  # {
  #   "auth": {
  #      "username":"johndoe@test.com",
  #      "token":"8yen21yn9182n91es",
  #      "signature":"hwfnociuhcinquohfnpioq"  # the token SIGNED with the secret key of the ig_identity api
  #      "role":"user",
  #      "expiry_date":"2412343",
  #      "ip_address":"123.345.234.123"  # can be used by relying party to ensure that token isn't stolen
  #   },
  #   "iv":"ssaf23123312123"  # initialization vector of the AES encrypted auth field
  # }
  # the above response is used as the POST data in a login request to the relying party

  def validate_login_data(user, data)
    raise IdentityError, USER_NOT_FOUND if user == nil

    password = data[:password]
    challenge = data[:challenge]

    # default to username and password validation
    if password != nil
      validate_incoming_password user, password
    else
      validate_incoming_challenge user, challenge
    end

  end

  def validate_incoming_challenge(user, challenge)
    # if the user doesn't have a public_key registered, then the challenge cannot be validated
    raise IdentityError, PUBLIC_KEY_NOT_REGISTERED if user.public_key.to_s == ''

    # validate the challenge
    validate_challenge user, challenge[:digest], challenge[:signature]

    user
  end

  def validate_incoming_password(user, password)
    password_salt = user[:password_salt]
    password_hash = user[:password_hash]

    result = HashGenerator.generate_password_hash password, password_salt
    raise IdentityError, INVALID_PASSWORD if result != password_hash
  end

  def validate_domain(domain)
    trust = @trust_service.get_by_domain(domain)
    raise IdentityError, DOMAIN_NOT_AUTHORIZED if trust == nil

    trust
  end

  def validate_challenge(user, digest, signature)
    raise IdentityError, USER_NOT_FOUND if user == nil

    # check that the challenge has been issued (check db)
    challenge = @challenge_service.get_unexpired_by_username user.username

    if challenge == nil
      raise IdentityError, INVALID_SIGNED_DATA
    else
      # compare the base64 encoded sha256 hashes
      challenge_hash = HashGenerator.generate_hash challenge.data
      raise IdentityError, INVALID_SIGNED_DATA if digest != challenge_hash
    end

    # now validate the challenge signature itself
    validate_signature digest, signature, user.public_key

  end

  def validate_signature(digest, signature, public_key)
    begin
      unless @signature_service.validate_signature digest, signature, public_key
        raise IdentityError, INVALID_SIGNATURE
      end
    rescue OpenSSL::PKey::ECError
      raise IdentityError, INVALID_SIGNATURE
    end

  end

  def expire_challenges(user)
    @challenge_service.delete(user.username) if user != nil
  end

  def generate_auth(user, fingerprint, trust, redirect)

    # get the api secret
    api_secret = @configuration_service.get_config[:api_secret_ecdsa_key]

    # create a token
    token = @token_service.create_token user.id, fingerprint
    token_uuid_digest = HashGenerator.generate_hash token.uuid

    # sign the token uuid digest with the api secret key
    signature = @signature_service.sign token_uuid_digest, api_secret

    # create plaintext data to encrypt
    plaintext_data = {
        :id => user.id,
        :username => user.username,
        :first_name => user.first_name,
        :last_name => user.last_name,
        :email => user.email,
        :mobile_number => user.mobile_number,
        :digest => token_uuid_digest,
        :signature => signature,
        :fingerprint => token.fingerprint,
        :role => user.role,
        :expiry_date => token.expires,
        :ip_address => '0.0.0.0'
    }.to_json

    encoded_plaintext_data = Base64.encode64 plaintext_data

    result = @cipher_service.aes_encrypt encoded_plaintext_data, trust.aes_key
    auth = {:token => token.uuid, :auth => result[:cipher_text], :iv => result[:iv]}

    # if redirect == true, redirect to the domain login uri, with the escaped JSON auth on the querystring
    if (redirect != nil) && (redirect)
      base64_escaped_auth = URI.escape(Base64.encode64(auth.to_json))
      redirect_uri = "#{trust.login_uri}/#{user.username}/#{base64_escaped_auth}"
      return {:redirect_uri => redirect_uri}
    end

    auth
  end

end