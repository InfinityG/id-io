require './api/services/hash_service'
require './api/services/config_service'
require './api/repositories/otp_repository'

class OtpService

  def initialize(otp_repository = OtpRepository, hash_service = HashService, config_service = ConfigurationService)
    @otp_repository = otp_repository.new
    @hash_service = hash_service.new
    @configuration_service = config_service.new
  end

  def create_otp(username, pin)
    nonce = @hash_service.generate_uuid
    save_otp username, pin, nonce
  end

  def get_token(nonce)
    otp = @otp_repository.get_otp_by_nonce(nonce)

    #check that the otp hasn't expired, if it has, delete it
    if otp != nil
      if otp.expires <= Time.now.to_i
        @otp_repository.delete_otp otp.id
        return nil
      end
      return otp
    end

    nil
  end

  private
  def save_otp(username, pin, nonce)
    timestamp = Time.now
    expires = timestamp + (@configuration_service.get_config[:otp_expiry])

    @otp_repository.create_otp(username, pin, nonce, expires.to_i)
  end
end