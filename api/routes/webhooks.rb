require 'sinatra/base'
require './api/models/user'
require './api/services/user_service'
require './api/utils/rest_util'
require 'json'

module Sinatra
  module WebhookRoutes
    def self.registered(app)

      app.post '/confirmations' do

        body = request.body.read
        puts body

        data = JSON.parse(body, :symbolize_names => true)

        begin

          if data[:type] == 'mobile'
            # this is a message received from the SMS API, eg: {"type":"mobile","data":"user@test.com|27827255159"}
            data_arr = data[:data].split('|')
            username = data_arr[0]
            number = data_arr[1]

            # look up the user identified by the number;
            # get the webhook (if there is one);
            # execute a request to the webhook endpoint(s)
            user_service = UserService.new
            user = user_service.get_by_username_and_mobile_number(username, number)

            if user != nil
              user.mobile_confirmed = true
              user_service.update user

              # now handle the webhooks if there are any;
              # eg: signing a contract condition
              if user.webhooks.length > 0
                user.webhooks.each do |webhook|
                  uri = webhook.uri
                  auth_header = webhook.headers[0]
                  body = webhook.body
                  RestUtil.new.execute_post(uri, auth_header, body)
                end
              end
            end

          end

          status 200
        rescue IdentityError => e
          status 500
          e.message.to_json
        end
      end

      app.post '/confirmations/facilitators' do

        body = request.body.read
        puts body

        data = JSON.parse(body, :symbolize_names => true)

        begin

          if data[:type] == 'mobile'
            # this is a message received from the SMS API,
            # eg: {"type":"mobile","data":"user@test.com|27827255159"}
            data_arr = data[:data].split('|')
            username = data_arr[0]
            number = data_arr[1]

            # look up the user identified by the number;
            # get the webhook (if there is one);
            # execute a request to the webhook endpoint(s)
            user_service = UserService.new
            user = user_service.get_by_username_and_mobile_number(username, number)

            if user != nil
              user.mobile_confirmed = true
              user_service.update user

              # now handle the webhooks if there are any;
              # eg: signing a contract condition
              if user.webhooks.length > 0
                user.webhooks.each do |webhook|
                  uri = webhook.uri
                  auth_header = webhook.headers[0]
                  body = webhook.body
                  RestUtil.new.execute_post(uri, auth_header, body)
                end
              end
            end

          end

          status 200
        rescue IdentityError => e
          status 500
          e.message.to_json
        end
      end

    end
  end
  register WebhookRoutes
end