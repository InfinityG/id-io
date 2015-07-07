require './api/services/signature_service'
require './api/services/cipher_service'
require './api/services/config_service'
require './api/services/token_service'
require './api/services/challenge_service'
require './api/services/trust_service'
require './api/services/hash_service'
require './api/errors/identity_error'
require 'base64'
require 'openssl'

class IdentityService
  include ErrorConstants::IdentityErrors

  def initialize(signature_service = SignatureService, config_service = ConfigurationService,
                 token_service = TokenService, challenge_service = ChallengeService,
                 trust_service = TrustService, hash_service = HashService, cipher_service = CipherService)
    @signature_service = signature_service.new
    @configuration_service = config_service.new
    @token_service = token_service.new
    @challenge_service = challenge_service.new
    @hash_service = hash_service.new
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
    validate_challenge user, challenge[:data], challenge[:signature]

    user
  end

  def validate_incoming_password(user, password)
    password_salt = user[:password_salt]
    password_hash = user[:password_hash]

    result = @hash_service.generate_password_hash password, password_salt
    raise IdentityError, INVALID_PASSWORD if result != password_hash
  end

  def validate_domain(domain)
    trust = @trust_service.get_by_domain(domain)
    raise IdentityError, DOMAIN_NOT_AUTHORIZED if trust == nil

    trust
  end

  def validate_challenge(user, challenge_data, challenge_signature)
    raise IdentityError, USER_NOT_FOUND if user == nil

    # NOTE: incoming challenge data will be base64 encoded as this is the requirement for signing -
    # we therefore need to base64 decode it to compare with the stored version!
    decoded_challenge_data = Base64.decode64 challenge_data

    # check that the challenge has been issued (check db)
    challenge = @challenge_service.get_unexpired_by_username user.username

    if (challenge == nil) || (challenge.data != decoded_challenge_data)
      raise IdentityError, INVALID_SIGNED_DATA
    end

    # now validate the challenge signature itself
    validate_signature challenge_data, challenge_signature, user.public_key

  end

  def validate_signature(data, signature, public_key)
    begin
      unless @signature_service.validate_signature data, signature, public_key
        raise IdentityError, INVALID_SIGNATURE
      end
    rescue OpenSSL::PKey::ECError
      raise IdentityError, INVALID_SIGNATURE
    end

  end

  def expire_challenges(user)
    @challenge_service.delete(user.username) if user != nil
  end

  def generate_auth(user, fingerprint, trust)

    # get the api secret
    api_secret = @configuration_service.get_config[:api_secret_ecdsa_key]

    # create a token
    token = @token_service.create_token user.id, fingerprint
    encoded_token_uuid = Base64.encode64 token.uuid

    # sign the token with the api secret key
    signed_token = @signature_service.sign encoded_token_uuid, api_secret

    # create plaintext data to encrypt
    plaintext_data = {
        :id => user.id,
        :username => user.username,
        :token => encoded_token_uuid,
        :fingerprint => token.fingerprint,
        :signature => signed_token,
        :role => user.role,
        :expiry_date => token.expires,
        :ip_address => '0.0.0.0'
    }.to_json

    encoded_plaintext_data = Base64.encode64 plaintext_data

    result = @cipher_service.aes_encrypt encoded_plaintext_data, trust.aes_key
    {:token => token.uuid, :auth => result[:cipher_text], :iv => result[:iv]}

  end

end