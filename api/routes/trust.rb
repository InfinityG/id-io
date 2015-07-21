require 'sinatra/base'
require './api/services/trust_service'
require 'json'

module Sinatra
  module TrustRoutes
    def self.registered(app)

      app.post '/trusts' do
        content_type :json

        data = JSON.parse(request.body.read, :symbolize_names => true)

        begin
          IdentityValidator.new.validate_trust data
        rescue ValidationError => e
          status 400 # bad request
          return e.message
        end

        domain = data[:domain]
        aes_key = data[:aes_key]
        login_uri = data[:login_uri]

        begin
          result = TrustService.new.create_or_update domain, aes_key, login_uri
          {:id => result.id}.to_json
        rescue IdentityError => e
          status 500
          e.message.to_json
        end
      end

    end
  end

  register TrustRoutes
end