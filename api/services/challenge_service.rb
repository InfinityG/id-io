require './api/models/challenge'
require './api/repositories/challenge_repository'
require './api/utils/random_generator'
require './api/errors/identity_error'
require './api/constants/error_constants'
require './api/services/config_service'

class ChallengeService
  include ErrorConstants::IdentityErrors
  include RandomGenerator

  def initialize(challenge_repository = ChallengeRepository, config_service = ConfigurationService)
    @challenge_repository = challenge_repository.new
    @configuration_service = config_service.new
  end

  def create(user)
    raise IdentityError, USER_NOT_FOUND if user == nil

    # delete any previous challenge for this user
    @challenge_repository.delete_for_user user.username

    # uuid
    uuid = RandomGenerator.generate_uuid

    # expiry
    timestamp = Time.now
    expires = (timestamp + (@configuration_service.get_config[:token_expiry])).to_i

    result = @challenge_repository.create_challenge user.username, uuid, expires

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