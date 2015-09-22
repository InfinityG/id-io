require 'sinatra/base'
require './api/services/connection_service'
require './api/errors/identity_error'
require './api/errors/validation_error'
require './api/validators/identity_validator'

module Sinatra
  module ConnectionRoutes
    def self.registered(app)

      # CREATE a 'friend' request - requires the payload to be signed by the origin user
      app.post '/connections' do
        content_type :json

        data = JSON.parse(request.body.read, :symbolize_names => true)

        begin
          IdentityValidator.new.validate_connection_request data
        rescue ValidationError => e
          status 400 # bad request
          return e.message
        end

        begin
          connection = ConnectionService.new.create(@current_user, data)
          status 201
          connection.to_json
        rescue IdentityError => e
          status 500
          return e.message.to_json
        end

      end

      # UPDATE a 'friend' request (confirmation) - requires the payload to be signed by the target user
      app.post '/connections/:connection_id' do
        content_type :json

        connection_id = params[:connection_id]
        data = JSON.parse(request.body.read, :symbolize_names => true)

        begin
          # check that the contact actually exists
          IdentityValidator.new.validate_connection_confirmation data
        rescue ValidationError => e
          status 400 # bad request
          return e.message
        end

        begin
          connection = ConnectionService.new.update(connection_id, @current_user, data)
          status 201
          connection.to_json
        rescue IdentityError => e
          status 500
          return e.message.to_json
        end

      end

      # get all of my contact requests as a user
      # single optional parameter: 'confirmed' (true - returns only confirmed connections; false - returns only
      #   unconfirmed connections)
      app.get '/connections' do
        confirmed = params[:confirmed]

        begin
          connections = ConnectionService.new.get_connections(@current_user, confirmed)
          status 200
          connections.to_json
        rescue IdentityError => e
          status 500
          return e.message.to_json
        end

      end

    end

  end
  register UserRoutes
end