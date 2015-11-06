require 'sinatra/base'
require './api/services/user_service'
require './api/services/otp_service'
require './api/errors/identity_error'
require './api/errors/validation_error'
require './api/validators/identity_validator'

module Sinatra
  module UserRoutes
    def self.registered(app)

      ########################
      # CREATE a new user
      ########################

      app.post '/users' do
        content_type :json

        data = JSON.parse(request.body.read, :symbolize_names => true)

        begin
          IdentityValidator.new.validate_new_user data
        rescue ValidationError => e
          status 400 # bad request
          return e.message
        end

        begin
          #create new user
          user = UserService.new.create(data)
          status 201
          user.to_json
        rescue IdentityError => e
          status 500
          return e.message.to_json
        end

      end


      ################################################
      # Initiate password reset flow with OTP generation
      ################################################

      # app.post '/users/recovery/otp' do
      app.post '/users/otp' do
        content_type :json

        data = JSON.parse(request.body.read, :symbolize_names => true)

        begin
          IdentityValidator.new.validate_otp_request data
        rescue ValidationError => e
          status 400 # bad request
          return e.message
        end

        begin
          #create new otp
          otp = OtpService.new.create_otp data[:username].to_s.downcase
          status 201
          otp.to_json
        rescue IdentityError => e
          status 400
          e.message.to_json
        end

      end

      app.post '/users/reset' do
        content_type :json

        data = JSON.parse(request.body.read, :symbolize_names => true)

        begin
          IdentityValidator.new.validate_reset_request data
        rescue ValidationError => e
          status 400 # bad request
          return e.message
        end

        begin
          username = data[:username].to_s.downcase
          otp = data[:otp]
          nonce = data[:nonce]
          password = data[:password]

          OtpService.new.confirm_otp username, otp, nonce
          user = UserService.new.update_password(username, password)
          status 200
          user.to_json
        rescue IdentityError => e
          status 400
          e.message.to_json
        end

      end

      ########################################
      # UPDATE a user (partial update so POST)
      ########################################

      app.post '/users/:username' do
        content_type :json

        #  ensure that the current logged in user is attempting to update his own data
        username = params[:username].to_s.downcase
        halt 401, 'Unauthorized' if username != @current_user.username

        data = JSON.parse(request.body.read, :symbolize_names => true)

        begin
          enforce_user_sig = ConfigurationService.new.get_config[:enforce_user_sig]
          IdentityValidator.new.validate_user_update data, enforce_user_sig
        rescue ValidationError => e
          status 400 # bad request
          return e.message
        end

        begin
          #update user
          user = UserService.new.update(@current_user, data)
          status 200
          user.to_json
        rescue IdentityError => e
          status 500
          return e.message.to_json
        end

      end

      #############################
      # User details
      #############################

      #get users
      app.get '/users' do
        content_type :json

        #handle paging
        index = params[:index].to_i
        count = params[:count].to_i

        user_service = UserService.new
        users = user_service.get_all
        total_count = users.length

        if index > 0 && count > 0

          start_index = (index * count) - count
          filtered_users = users[start_index, count]
          total_page_count = total_count/count + (total_count%count)

          return {
              :total_page_count => total_page_count,
              :current_page => index,
              :total_record_count => total_count,
              :page_record_count => filtered_users.length,
              :start_index => start_index,
              :end_index => start_index + (filtered_users.length - 1),
              :users => filtered_users
          }.to_json
        end

        {
            :total_page_count => 1,
            :current_page => 1,
            :total_record_count => total_count,
            :page_record_count => total_count,
            :start_index => 0,
            :end_index => total_count - 1,
            :users => users
        }.to_json
      end

      #get user details
      app.get '/users/:user_id' do
        content_type :json

        user_id = params[:origin_user_id]
        user_service = UserService.new
        user = user_service.get_by_id user_id
        user.to_json
      end

      #get all users that have been registered by another user (denoted by username)
      app.get '/users/associations' do
        content_type :json

        user_id = @current_user.id
        current_user = UserService.new.get_by_id user_id

        halt 401, 'Unauthorized' if current_user == nil

        username = current_user.username
        user_service = UserService.new
        users = user_service.get_associated_users_by_username username

        # filter - don't include certain fields (password etc)
        result = []

        users.each do |user|
          result << {
              :id => user.id,
              :username => user.username,
              :first_name => user.first_name,
              :last_name => user.last_name,
              :role => user.role,
              :public_key => user.public_key,
              :registrar => user.registrar,
              :mobile_number => user.mobile_number
          }
        end

        result.to_json
      end

    end

  end
  register UserRoutes
end