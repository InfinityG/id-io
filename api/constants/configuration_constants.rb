require 'openssl'

module ConfigurationConstants
  module Environments
    DEVELOPMENT = {
        :host => '0.0.0.0',
        :port => 9002,
        :api_auth_token => '7b2ebe64dc9149ac8a9e923bf2a6b233',
        :api_secret_ecdsa_key => '5be6kLnncgd+eap2De+acPFrrYyhX51paQz7cXHKsqY=',
        :api_public_ecdsa_key => 'A1blXQkf5AH7pfNNx2MIwNXytCyV/wxmQOt7ZGgccvVQ',
        :mongo_host => 'localhost',
        :mongo_port => 27017, # default is 27017
        :mongo_db => 'id-io',
        :logger_file => 'app_log.log',
        :logger_age => 10,
        :logger_size => 1024000,
        :default_request_timeout => 60,
        :allowed_origin => '*',
        :token_expiry => 3600,
        :challenge_expiry => 3600,
        :sms_api_message_uri => 'http://localhost:9004/messages/outbound',
        :sms_api_auth_token => '7b2ebe64dc9149ac8a9e923bf2a6b233',
        :confirmation_webhook_uri => 'http://localhost:9002/confirmations',
        :confirm_number_template => 'Congratulations! A new web identity has been created for you. ' +
            'Reply %{SHORT_HASH} to %{REPLY_NUMBER} to activate your registration.',
        :ripple_rest_uri => '',
        :ripple_default_currency => 'IDO',
        :ripple_max_transaction_fee => '100000',    # in Ripple 'drops'
        :ripple_hot_wallet_secret =>'',
        :ripple_hot_wallet_address =>'',
        :ripple_cold_wallet_address =>'',
        :ripple_identity_wallet_address =>''
    }

    TEST = {
        :host => '0.0.0.0',
        :port => 9002,
        :api_auth_token => '7b2ebe64dc9149ac8a9e923bf2a6b233',
        :api_secret_ecdsa_key => '5be6kLnncgd+eap2De+acPFrrYyhX51paQz7cXHKsqY=',
        :api_public_ecdsa_key => 'A1blXQkf5AH7pfNNx2MIwNXytCyV/wxmQOt7ZGgccvVQ',
        :mongo_host => 'localhost',
        :mongo_port => 27017, # default is 27017
        :mongo_db => 'id-io',
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
        :ripple_hot_wallet_secret =>'',
        :ripple_hot_wallet_address =>'',
        :ripple_cold_wallet_address =>'',
        :ripple_identity_wallet_address =>''
    }


    PRODUCTION = {
        # :host => '0.0.0.0',
        # :port => 9002,
        # :api_auth_token => '7b2ebe64dc9149ac8a9e923bf2a6b233',
        # :api_secret_ecdsa_key => '5be6kLnncgd+eap2De+acPFrrYyhX51paQz7cXHKsqY=',
        # :api_public_ecdsa_key => 'A1blXQkf5AH7pfNNx2MIwNXytCyV/wxmQOt7ZGgccvVQ',
        # :mongo_host => 'localhost',
        # :mongo_port => 27017, # default is 27017
        # :mongo_db => 'id-io',
        # :logger_file => 'app_log.log',
        # :logger_age => 10,
        # :logger_size => 1024000,
        # :default_request_timeout => 60,
        # :allowed_origin => '*',
        # :token_expiry => 3600,
        # :challenge_expiry => 3600,
        # :sms_api_message_uri => '',
        # :sms_api_auth_token => '',
        # :confirmation_webhook_uri => '',
        # :confirm_number_template => 'Congratulations! A new web identity has been created for you. ' +
        #     'Reply %{SHORT_HASH} to %{REPLY_NUMBER} to activate your registration.',
        # :ripple_rest_uri => '',
        # :ripple_default_currency => 'IDO',
        # :ripple_max_transaction_fee => '100000',    # in Ripple 'drops'
        # :ripple_hot_wallet_secret =>'',
        # :ripple_hot_wallet_address =>'',
        # :ripple_cold_wallet_address =>'',
        # :ripple_identity_wallet_address =>'',
    }
  end
end