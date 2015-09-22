require 'openssl'

module ConfigurationConstants
  module Environments
    DEVELOPMENT = {
        :host => '0.0.0.0',
        :port => 9002,
        :api_auth_token => ENV['API_AUTH_TOKEN'],
        :api_secret_ecdsa_key => ENV['API_SECRET_KEY'],
        :api_public_ecdsa_key => ENV['API_PUBLIC_KEY'],
        :mongo_host => 'localhost',
        :mongo_port => 27017, # default is 27017
        :mongo_db => ENV['MONGO_DB'],
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => '*',
        :token_expiry => 3600,
        :challenge_expiry => 3600,
        :sms_api_message_uri => 'http://localhost:9004/messages/outbound',
        :sms_api_auth_token => ENV['SMS_API_AUTH_TOKEN'],
        :confirmation_webhook_uri => 'http://localhost:9002/confirmations',
        :confirm_number_template => 'Congratulations! A new web identity has been created for you. ' +
            'Reply %{SHORT_HASH} to %{REPLY_NUMBER} to activate your registration.',
        :ripple_rest_uri => '',
        :ripple_default_currency => 'IDO',
        :ripple_max_transaction_fee => '100000',    # in Ripple 'drops'
        :ripple_hot_wallet_secret => ENV['RIPPLE_HOT_SECRET'],
        :ripple_hot_wallet_address => ENV['RIPPLE_HOT_ADDRESS'],
        :ripple_cold_wallet_address => ENV['RIPPLE_COLD_ADDRESS'],
        :ripple_identity_wallet_address => ENV['RIPPLE_ID_WALLET_ADDRESS']
    }

    TEST = {
        :host => '0.0.0.0',
        :port => 9002,
        :api_auth_token => ENV['API_AUTH_TOKEN'],
        :api_secret_ecdsa_key => ENV['API_SECRET_KEY'],
        :api_public_ecdsa_key => ENV['API_PUBLIC_KEY'],
        :mongo_host => ENV['MONGO_HOST'],
        :mongo_port => 27017, # default is 27017
        :mongo_db => ENV['MONGO_DB'],
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => '*',
        :token_expiry => 3600,
        :challenge_expiry => 3600,
        :sms_api_message_uri => '',
        :sms_api_auth_token => '',
        :confirmation_webhook_uri => '',
        :confirm_number_template => 'Congratulations! A new web identity has been created for you. ' +
            'Reply %{SHORT_HASH} to %{REPLY_NUMBER} to activate your registration.',
        :ripple_rest_uri => '',
        :ripple_default_currency => 'IDO',
        :ripple_max_transaction_fee => '100000',    # in Ripple 'drops'
        :ripple_hot_wallet_secret => ENV['RIPPLE_HOT_SECRET'],
        :ripple_hot_wallet_address => ENV['RIPPLE_HOT_ADDRESS'],
        :ripple_cold_wallet_address => ENV['RIPPLE_COLD_ADDRESS'],
        :ripple_identity_wallet_address => ENV['RIPPLE_ID_WALLET_ADDRESS']
    }

    PRODUCTION = {
        :host => '0.0.0.0',
        :port => 9002,
        :api_auth_token => ENV['API_AUTH_TOKEN'],
        :api_secret_ecdsa_key => ENV['API_SECRET_KEY'],
        :api_public_ecdsa_key => ENV['API_PUBLIC_KEY'],
        :mongo_host => 'localhost',
        :mongo_port => 27017, # default is 27017
        :mongo_db => ENV['MONGO_DB'],
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => '*',
        :token_expiry => 3600,
        :challenge_expiry => 3600,
        :sms_api_message_uri => '',
        :sms_api_auth_token => '',
        :confirmation_webhook_uri => '',
        :confirm_number_template => 'Congratulations! A new web identity has been created for you. ' +
            'Reply %{SHORT_HASH} to %{REPLY_NUMBER} to activate your registration.',
        :ripple_rest_uri => '',
        :ripple_default_currency => 'IDO',
        :ripple_max_transaction_fee => '100000',    # in Ripple 'drops'
        :ripple_hot_wallet_secret => ENV['RIPPLE_HOT_SECRET'],
        :ripple_hot_wallet_address => ENV['RIPPLE_HOT_ADDRESS'],
        :ripple_cold_wallet_address => ENV['RIPPLE_COLD_ADDRESS'],
        :ripple_identity_wallet_address => ENV['RIPPLE_ID_WALLET_ADDRESS']
    }
  end
end
