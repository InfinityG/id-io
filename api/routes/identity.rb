require 'sinatra/base'
require './api/services/identity_service'
require './api/errors/validation_error'
require './api/errors/identity_error'
require './api/validators/identity_validator'
require 'json'

module Sinatra
  module IdentityRoutes
    def self.registered(app)

      # STEP 1:
      # this starts a flow where a challenge is returned which then needs to be signed by the consumer
      # the signed challenge is sent to the '/login' route below
      # payload structure:
      # {
      #   "username": "johndoe@test.com"
      # }

      app.post '/challenge' do
        data = JSON.parse(request.body.read, :symbolize_names => true)

        begin
          username = data[:username]
          result = ChallengeService.new.create username
          result.to_json
        rescue IdentityError => e
          status 500
          e.message.to_json
        end
      end

      # STEP 2:
      # NOTE: if STEP 1 isn't performed, the login step needs a password instead of a challenge.
      # payload structure:
      # {
      #   "username":"johndoe@test.com",
      #   "password":"password",  # absence of this requires the signed_challenge field
      #   "challenge":{
      #           "data":"asaf98yqiwehdqsdlnqpodo",
      #           "signature":"ksndaihqiuwehfiuahsdfaisf"
      #         }
      #   "domain":"api.smartcontracts.com"   # relying party
      # }
      #

      app.post '/login' do
        data = JSON.parse(request.body.read, :symbolize_names => true)

        begin
            IdentityValidator.new.validate_login data
        rescue ValidationError => e
           status 400 # bad request
            return e.message
        end

        # passed basic input validation, now validate actual data
        identity_service = IdentityService.new
        user_service = UserService.new
        user = nil

        begin
          user = user_service.get_by_username(data[:username])
          fingerprint = data[:fingerprint]
          identity_service.validate_login_data user, data
          trust = identity_service.validate_domain data
          result = identity_service.generate_auth user, fingerprint, trust
          result.to_json
        rescue IdentityError => e
          status 401
          e.message.to_json
        ensure
          # need to remove any challenges for this user so they can't be re-used
          identity_service.expire_challenges user
        end

      end

    end
  end
  register IdentityRoutes
end