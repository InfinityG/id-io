require './api/utils/random_generator'
require './api/services/config_service'
require './api/repositories/token_repository'

class TokenService
include RandomGenerator

  def initialize(token_repository = TokenRepository, config_service = ConfigurationService)
    @token_repository = token_repository.new
    @configuration_service = config_service.new
  end

  def create_token(user_id, fingerprint)
    uuid = RandomGenerator.generate_uuid
    save_token user_id, uuid, fingerprint
  end

  def get_token(uuid)
    token = @token_repository.get_token(uuid)

    #check that the token hasn't expired, if it has, delete it
    if token != nil
      if token.expires <= Time.now.to_i
        @token_repository.delete_token token.id
        return nil
      end
      return token
    end

    nil
  end

  private
  def save_token(user_id, token, fingerprint)
    timestamp = Time.now
    expires = timestamp + (@configuration_service.get_config[:token_expiry])

    @token_repository.save_token(user_id, token, fingerprint, expires.to_i)
  end
end