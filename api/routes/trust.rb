require 'sinatra/base'
require './api/services/trust_service'
require 'json'

module Sinatra
  module TrustRoutes
    def self.registered(app)

      app.post '/trusts' do
        content_type :json

        data = JSON.parse(request.body.read, :symbolize_names => true)
        domain = data[:domain]
        aes_key = data[:aes_key]

        begin
          result = TrustService.new.create_or_update domain, aes_key
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