require './api/utils/rest_util'
require './api/utils/key_provider'
require './api/services/config_service'
require './api/constants/error_constants'
require './api/errors/identity_error'
require 'json'

class SmsGateway
  include ErrorConstants::IdentityErrors

  def initialize(rest_util = RestUtil, config_service = ConfigurationService)
    @rest_util = rest_util.new
    @config = config_service.new.get_config
  end

  def send_sms(mobile_number, message)
    data = {
        :number => mobile_number,
        :message => message
    }

    uri= "#{@config[:sms_api_host]}/messages/outbound"
    auth_header = @config[:sms_api_auth_token]

    begin
      response = @rest_util.execute_post(uri, data.to_json, auth_header)
      if response.response_code != 200
        message = "#{SMS_DELIVERY_ERROR} | Response code: #{response.response_code}"
        raise IdentityError, message
      end
      return response
    rescue RestClient::Exception => e
      message = "#{SMS_DELIVERY_ERROR}: #{e.http_code} | #{e.http_body}"
      raise IdentityError, message
    end
  end
end