require './api/models/challenge'
require './api/repositories/challenge_repository'
require './api/utils/hash_generator'
require './api/errors/identity_error'
require './api/constants/error_constants'
require './api/services/config_service'

class ChallengeService
  include ErrorConstants::IdentityErrors

  def initialize(challenge_repository = ChallengeRepository, user_service = UserService, hash_service = HashService,
  config_service = ConfigurationService)
    @challenge_repository = challenge_repository.new
    @user_service = user_service.new
    @hash_service = hash_service.new
    @configuration_service = config_service.new
  end

  def create(username)
      # ensure user exists
      user = @user_service.get_by_username username
      raise IdentityError, USER_NOT_FOUND if user == nil

      # delete any previous challenge for this user
      @challenge_repository.delete_for_user username

      # uuid
      uuid = @hash_service.generate_uuid

      # expiry
      timestamp = Time.now
      expires = (timestamp + (@configuration_service.get_config[:token_expiry])).to_i

      result = @challenge_repository.create_challenge username, uuid, expires

      {:data => result.data}
  end

  def get_unexpired_by_username(username)
    result = @challenge_repository.get_challenge username

    if result != nil
      now = Date.today.to_time
      time_to_validate = Time.at result.expires

      return result if time_to_validate > now
    end

    nil

  end

  def delete(username)
    @challenge_repository.delete_for_user username
  end

end