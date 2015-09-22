require 'sinatra/base'
require './api/services/token_service'
require './api/services/user_service'
require './api/services/config_service'

module Sinatra
  module AuthRoutes
    def self.registered(app)

      app.before do

        path = request.path_info
        method = request.request_method

        # the following are allowed without an Authorization header:
        # - OPTIONS
        # - creating a new user (registration)
        # - creating a new challenge
        # - logging in

        if (method == 'OPTIONS') ||
            (method == 'POST' && path == '/users') ||
            (method == 'POST' && path == '/challenge') ||
            (method == 'POST' && path == '/login')
          return
        else

          # all other routes require an Authorization header, the value of which is either:

          # 1. an admin (API) auth token (a configuration constant), required for:
          #   - POST /confirmations (webhook callbacks)
          #   - POST /trusts (create  trust relationship with a 3rd party)
          #   - GET /users (get a list of users)

          # OR

          # 2. a user-specific token (required for the following routes):
          #   - POST & GET /users/associations/{user}
          #   - GET /connections

          auth_header = env['HTTP_AUTHORIZATION']

          if auth_header == nil
            halt 401, 'Unauthorized!'
          end

          # api auth token routes - use the api token in the config file
          if (path.include? '/confirmations') || (path == '/users') || (path == '/trusts')
            api_auth = ConfigurationService.new.get_config[:api_auth_token]
            halt 401, 'Unauthorized!' if api_auth != auth_header
          end

          # specific user token routes - need the auth token generated by ID-IO
          if (path.include? '/users/associations') || (path.include? '/connections')
            token = TokenService.new.get_token(auth_header)

            if token == nil
              halt 401, 'Unauthorized!'
            else
              # the current user context is set using the user id of the token
              user = UserService.new.get_by_id token[:user_id]

              halt 401, 'Unauthorized!' if user == nil

              @current_user = user
              # @current_user_id = token[:user_id]
              @current_user_role = user[:role]
            end
          end
        end
      end

    end
  end

  register AuthRoutes
end