#config.ru
# see http://bundler.io/v1.3/sinatra.html

# require 'rubygems'
# require 'bundler'

# Bundler.require

require './app'
require 'webrick'
require './api/services/config_service'

options = ConfigurationService.new.get_server_config

# run ApiApp
Rack::Handler::WEBrick.run ApiApp, options do |server|
  [:INT, :TERM].each do |sig|
    trap(sig) do
      server.shutdown
    end
  end
end

# start this with 'rackup' to start in development environment. Switch '-p' for port is not required as this is detected
# from configuration. eg:

# 'rackup -E development' for development environment
# 'rackup -E test' for test environment
# 'rackup -E production' for production environment