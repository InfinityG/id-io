require './api/utils/rest_util'
require './api/utils/key_provider'
require './api/services/config_service'
require 'json'
require 'uri'

class RippleRestGateway

  def initialize(config_service = ConfigurationService, rest_util = RestUtil)
    @config = config_service.new.get_config
    @rest_util = rest_util.new
  end

  def generate_wallet
    uri = "#{@config[:ripple_rest_uri]}/v1/wallet/new"

    result = @rest_util.execute_get uri
    JSON.parse(result.response_body, :symbolize_names => true)
  end

  def create_trust_line(ripple_address, ripple_secret, limit, currency, counterparty_address)
    uri = "#{@config[:ripple_rest_uri]}/v1/accounts/#{ripple_address}/trustlines"
    payload = {
        :secret => ripple_secret,
        :trustline => {
            :limit => limit,
            :currency => currency,
            :counterparty => counterparty_address,
            :allows_rippling => false
        }
    }

    response = @rest_util.execute_post uri, payload
    result = JSON.parse(response.response_body, :symbolize_names => true)

    raise IdentityError, "#{TRANSACTION_ERROR}: #{result[:message]}" unless result[:success]

    result[:success]
  end

  # Uri: /v1/accounts/{address}/payments/paths/{destination_account}/{destination_amount as value+currency or value+currency+issuer}
  def prepare_deposit(tag, amount, memo_hash)
    destination_amount = "#{amount}+#{@config[:ripple_default_currency]}"
    uri = "#{@config[:ripple_rest_uri]}/v1/accounts/#{@config[:ripple_hot_wallet_address]}/payments/paths/" +
        "#{@config[:ripple_identity_wallet_address]}/#{destination_amount}"

    execute_preparation_request uri, tag, memo_hash
  end

  # Payments from gateway hot wallet to identity wallet
  # Uri: /v1/accounts/{source_address}/payments
  def create_deposit(resource_id, payment)
    uri = "#{@config[:ripple_rest_uri]}/v1/accounts/#{@config[:ripple_cold_wallet_address]}/payments"
    payload = {
        :secret => @config[:ripple_hot_wallet_secret],
        :max_fee => @config[:ripple_max_transaction_fee],
        :client_resource_id => resource_id,
        :payment => payment
    }.to_json

    response = @rest_util.execute_post uri, payload
    result = JSON.parse(response.response_body, :symbolize_names => true)

    raise IdentityError, "#{TRANSACTION_ERROR}: #{result[:message]}" unless result[:success]

    URI(result[:status_url]).path

  end

  def confirm_transaction(status_path)
    response = @rest_util.execute_get status_path
    result = JSON.parse(response.response_body, :symbolize_names => true)

    raise IdentityError, "#{TRANSACTION_ERROR}: #{result[:message]}" unless result[:success]

    {
        :status => result[:state],
        :result => result[:payment][:result],
        :ledger_id => result[:ledger].to_i,
        :payment_hash => result[:hash],
        :ledger_timestamp => result[:payment][:timestamp],
        :amount => result[:payment][:destination_amount][:value].to_i,
        :currency => result[:payment][:destination_amount][:currency]
    }

  end

  #### HELPERS ###

  private
  def execute_preparation_request(uri, tag, memo_hash)
    response = @rest_util.execute_get uri
    result = JSON.parse(response.response_body, :symbolize_names => true)

    raise IdentityError, "#{TRANSACTION_ERROR}: #{result[:message]}" unless result[:success]

    update_payment_details result, tag, memo_hash
  end

  private
  def update_payment_details(json, tag, memo_hash)

    payment = json[:payments][0]
    # payment[:source_tag] = tag
    # payment[:source_amount][:issuer] = @config[:ripple_cold_wallet_address]
    # payment[:destination_tag] = tag
    # payment[:destination_amount][:issuer] = @config[:ripple_hot_wallet_address]

    arr = []

    memo_hash.each do |key, value|
      arr << {:MemoType => key, :MemoData => value}
    end

    payment[:memos] = arr

    payment
  end

end