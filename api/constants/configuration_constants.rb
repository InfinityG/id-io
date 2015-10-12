require 'openssl'

module ConfigurationConstants
  module Environments
    DEVELOPMENT = {
        :host => '0.0.0.0',
        :port => 9002,
        :api_auth_token => ENV['API_AUTH_TOKEN'],
        :api_secret_ecdsa_key => ENV['API_SECRET_KEY'],
        :api_public_ecdsa_key => ENV['API_PUBLIC_KEY'],
        :mongo_replicated => ENV['MONGO_REPLICATED'],
        :mongo_host_1 => ENV['MONGO_HOST_1'],
        :mongo_host_2 => nil,
        :mongo_host_3 => nil,
        :mongo_db => ENV['MONGO_DB'],
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => '*',
        :token_expiry => 3600,
        :otp_expiry => 300,
        :otp_test_mode => true,
        :otp_test_pin => '9999',
        :challenge_expiry => 3600,
        :enforce_user_sig => false,
        :sms_api_host => ENV['SMS_API_HOST'],
        :sms_api_auth_token => ENV['SMS_API_AUTH_TOKEN'],
        :confirmation_webhook_uri => 'http://localhost:9002/confirmations',
        :confirm_number_template => 'Congratulations! A new identity has been created for you. ' +
            'Reply %{SHORT_HASH} to %{REPLY_NUMBER} to activate your registration.',
        :forgotten_password_sms_template => 'You have requested to reset your password. Your one time PIN is %{SHORT_HASH}.'
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
        :mongo_replicated => ENV['MONGO_REPLICATED'],
        :mongo_host_1 => ENV['MONGO_HOST_1'],
        :mongo_host_2 => nil,
        :mongo_host_3 => nil,
        :mongo_db => ENV['MONGO_DB'],
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => '*',
        :token_expiry => 3600,
        :otp_expiry => 300,
        :otp_test_mode => false,
        :otp_test_pin => nil,
        :challenge_expiry => 3600,
        :enforce_user_sig => false,
        :sms_api_host => ENV['SMS_API_HOST'],
        :sms_api_auth_token => ENV['SMS_API_AUTH_TOKEN'],
        :confirmation_webhook_uri => '',
        :confirm_number_template => 'Congratulations! A new identity has been created for you. ' +
            'Reply %{SHORT_HASH} to %{REPLY_NUMBER} to activate your registration.',
        :ripple_rest_uri => '',
        :ripple_default_currency => 'IDO',
        :ripple_max_transaction_fee => '100000',    # in Ripple 'drops'
        :ripple_hot_wallet_secret => ENV['RIPPLE_HOT_SECRET'],
        :ripple_hot_wallet_address => ENV['RIPPLE_HOT_ADDRESS'],
        :ripple_cold_wallet_address => ENV['RIPPLE_COLD_ADDRESS'],
        :ripple_identity_wallet_address => ENV['RIPPLE_ID_WALLET_ADDRESS']
        :forgotten_password_sms_template => 'You have requested to reset your password. Your one time PIN is %{SHORT_HASH}.'
    }

    PRODUCTION = {
        :host => '0.0.0.0',
        :port => 9002,
        :api_auth_token => ENV['API_AUTH_TOKEN'],
        :api_secret_ecdsa_key => ENV['API_SECRET_KEY'],
        :api_public_ecdsa_key => ENV['API_PUBLIC_KEY'],
        :mongo_replicated => ENV['MONGO_REPLICATED'],
        :mongo_host_1 => ENV['MONGO_HOST_1'],
        :mongo_host_2 => ENV['MONGO_HOST_2'],
        :mongo_host_3 => ENV['MONGO_HOST_3'],
        :mongo_db => ENV['MONGO_DB'],
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => '*',
        :token_expiry => 3600,
        :otp_expiry => 300,
        :otp_test_mode => false,
        :otp_test_pin => nil,
        :challenge_expiry => 3600,
        :enforce_user_sig => false,
        :sms_api_host => ENV['SMS_API_HOST'],
        :sms_api_auth_token => ENV['SMS_API_AUTH_TOKEN'],
        :confirmation_webhook_uri => '',
        :confirm_number_template => 'Congratulations! A new identity has been created for you. ' +
            'Reply %{SHORT_HASH} to %{REPLY_NUMBER} to activate your registration.',
        :forgotten_password_sms_template => 'You have requested to reset your password. Your one time PIN is %{SHORT_HASH}.'
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
