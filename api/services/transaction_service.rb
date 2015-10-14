require './api/gateways/ripple_rest_gateway'
require './api/utils/hash_generator'
require './api/repositories/transaction_repository'
require './api/services/config_service'


class TransactionService

  include HashGenerator

  def initialize(ripple_rest_gateway = RippleRestGateway, hash_generator = HashGenerator,
                 transaction_repository = TransactionRepository, config_service = ConfigurationService)
    @ripple_gateway = ripple_rest_gateway.new
    @transaction_repository = transaction_repository.new
    @config = config_service.new.get_config
  end

  def execute_deposit(user, amount, memo_hash)
    client_resource_id = HashGenerator.generate_uuid
    payment = @ripple_gateway.prepare_deposit user[:id].to_s, amount, memo_hash

    # see https://ripple.com/build/transactions/#transaction-results
    status_url = @ripple_gateway.create_deposit(client_resource_id, payment)

    @transaction_repository.save_transaction user.id.to_s, client_resource_id, 'id_create', amount.to_s,
                                             @config[:ripple_default_currency],
                                             "#{@config[:ripple_rest_uri]}#{status_url}"
  end

  def get_transactions(user_id)
    @transaction_repository.get_transactions(user_id)
  end

  def get_transaction(transaction_id, user_id = nil)
    if user_id == nil
      @transaction_repository.get_transaction transaction_id
    else
      @transaction_repository.get_transaction_by_user_id user_id, transaction_id
    end
  end

  def get_pending_transactions
    @transaction_repository.get_transactions_by_status 'pending'
  end

  def save_transaction(user_id, resource_id, type, amount, currency, confirmation_url)
    @transaction_repository.save_transaction user_id, resource_id, type, amount, currency, confirmation_url
  end

  def confirm_transaction(transaction, confirmation_result)
    @transaction_repository.confirm_transaction transaction, confirmation_result
  end

end