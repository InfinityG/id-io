require 'base64'
require './api/services/config_service'

class KeyProvider
  def get_admin_key
    config = ConfigurationService.new.get_config
    Base64.strict_encode64("#{config[:admin_username]}:#{config[:admin_password]}").chomp  #.gsub('=', '')
  end
end