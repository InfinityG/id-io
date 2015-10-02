require './api/models/user'
require './api/models/webhook'
require './api/repositories/user_repository'
require './api/services/config_service'
require './api/services/challenge_service'
require './api/services/identity_service'
require './api/utils/hash_generator'
require './api/utils/rest_util'
require './api/constants/error_constants'
require './api/errors/identity_error'
require 'json'

class UserService
  include ErrorConstants::IdentityErrors
  include HashGenerator

  def initialize(user_repository = UserRepository,
                 config_service = ConfigurationService, challenge_service = ChallengeService,
                 identity_service = IdentityService, rest_util = RestUtil)
    @user_repository = user_repository.new
    @config = config_service.new.get_config
    @challenge_service = challenge_service.new
    @identity_service = identity_service.new
    @rest_util = rest_util.new
  end

  # register a new user
  def create(data)
    first_name = data[:first_name]
    last_name = data[:last_name]
    username = data[:username]
    password = data[:password]
    email = data[:email]
    public_key = data[:public_key]
    role = data[:role]
    mobile_number = data[:mobile_number]
    confirm_mobile = data[:confirm_mobile]
    webhooks = data[:webhooks]
    registrar = data[:registrar]
    meta = data[:meta]

    # check user doesn't already exist
    raise IdentityError, USERNAME_EXISTS if get_by_username(username) != nil

    # create salt and hash
    salt = HashGenerator.generate_salt
    hashed_password = HashGenerator.generate_password_hash password, salt

    # save user
    user = @user_repository.save_user first_name, last_name, username, salt, hashed_password,
                                      public_key, email, role, mobile_number, webhooks, registrar, meta

    # send confirmation sms if this is required
    send_confirmation_sms(username, mobile_number) if confirm_mobile

    # create a challenge on the response so that subsequent login doesn't require an additional challenge step
    challenge_data = @challenge_service.create user

    {:id => user.id, :username => user.username, :challenge => challenge_data}
  end

  #TODO: refactor this to handle paging
  def get_all
    @user_repository.get_all_users
  end

  def get_by_id(user_id)
    @user_repository.get_user user_id
  end

  def get_by_username_and_mobile_number(username, mobile_number)
    @user_repository.get_by_username_and_mobile(username, mobile_number)
  end

  def get_by_username(username)
    @user_repository.get_by_username username
  end

  def get_associated_users_by_username(username)
    @user_repository.get_associated_users_by_username username
  end

  def update_password(username, password)
    user = get_by_username username
    update(user, {:password => password})
    {:id => user.id.to_s, :username => user.username}
  end

  def update(current_user, data)
    if @config[:enforce_signature_based_auth]
      # first validate the signature
      digest = data[:digest]
      signature = data[:signature]

      # before we do anything we need to confirm the signature
      @identity_service.validate_signature digest, signature, current_user.public_key
    end

    # the new values for password and public key
    password = data[:password].to_s
    public_key = data[:public_key].to_s

    if password != ''
      # create salt and hash
      salt = HashGenerator.generate_salt
      hashed_password = HashGenerator.generate_password_hash password, salt
      current_user.password_salt = salt
      current_user.password_hash = hashed_password
    end

    if public_key != ''
      current_user.public_key = public_key
    end

    # now save
    @user_repository.update_user current_user

    {:id => current_user.id, :username => current_user.username, :public_key => current_user.public_key}
  end

  def confirm_mobile(username, mobile_number)
    user = get_by_username(username)
    raise IdentityError, USER_NOT_FOUND if user == nil
    raise IdentityError, INVALID_MOBILE_FOR_USER if user.mobile_number != mobile_number

    user.mobile_confirmed = true
    @user_repository.update_user user
  end

  def confirm_email(username, email)
    user = get_by_username(username)
    raise IdentityError, USER_NOT_FOUND if user == nil
    raise IdentityError, INVALID_EMAIL_FOR_USER if user.email != email

    user.email_confirmed = true
    @user_repository.update_user user
  end

  def delete(username)
    #TODO: delete from the DB - username is the identifier
    raise 'User delete not implemented'
  end

  private
  def send_confirmation_sms(username, mobile_number)
    # sms api uri, auth and message
    sms_api_uri = @config[:sms_api_message_uri]
    sms_api_auth_token = @config[:sms_api_auth_token]
    sms_message = @config[:confirm_number_template]

    # callback webhook - this is used by the sms api to call back into the identity api
    sms_webhook_body = {
        :type => 'mobile',
        :data => "#{username}|#{mobile_number}"
    }.to_json

    sms_webhook = {
        :uri => @config[:confirmation_webhook_uri],
        :auth_header => @config[:api_auth_token],
        :body => sms_webhook_body
    }

    confirm_number_payload = {
        :number => mobile_number,
        :message => sms_message,
        :webhook => sms_webhook
    }.to_json

    @rest_util.execute_post sms_api_uri, sms_api_auth_token, confirm_number_payload
  end

end