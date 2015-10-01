require './api/utils/random_generator'
require './api/services/config_service'
require './api/repositories/otp_repository'
require './api/repositories/user_repository'
require './api/gateways/sms_gateway'
require './api/errors/identity_error'
require './api/constants/error_constants'

class OtpService

  include ErrorConstants::IdentityErrors
  include RandomGenerator

  def initialize(otp_repository = OtpRepository, user_repository = UserRepository,
                 config_service = ConfigurationService, sms_gateway = SmsGateway)
    @otp_repository = otp_repository.new
    @user_repository = user_repository.new
    @configuration_service = config_service.new
    @config = config_service.new.get_config
    @sms_gateway = sms_gateway.new
  end

  def create_otp(username)
    user = @user_repository.get_by_username username

    raise IdentityError, USER_NOT_FOUND if user == nil
    raise IdentityError, MOBILE_NUMBER_NOT_REGISTERED if user.mobile_number.to_s == ''

    nonce = RandomGenerator.generate_uuid

    if !@config[:otp_test_mode]
      pin = RandomGenerator.generate_numeric 4
      message = @config[:forgotten_password_sms_template] % {:SHORT_HASH => pin}
      @sms_gateway.send_sms user.mobile_number, message
    else
      pin = @config[:otp_test_pin]
    end

    save_otp username, pin, nonce

    {:status => 'sent', :nonce => nonce}
  end

  def confirm_otp(username, pin, nonce)
    otp = get_otp nonce

    raise IdentityError, OTP_NOT_FOUND if otp == nil

    if otp != nil && otp.pin == pin && otp.username == username
      @otp_repository.delete_otp otp.id.to_s # immediately kill the otp so that it can't be reused
      return true
    end

    false
  end

  private
  def get_otp(nonce)
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

  def save_otp(username, pin, nonce)
    timestamp = Time.now
    expires = timestamp + (@config[:otp_expiry])

    @otp_repository.create_otp(username, pin, nonce, expires.to_i)
  end

end