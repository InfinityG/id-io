require 'mongo_mapper'
require 'bson'
require './api/models/transaction'

class TransactionRepository
  include Mongo
  include MongoMapper
  include BSON
  include SmartIdentity::Models

  def get_transactions(user_id)
    Transaction.all(:user_id => user_id)
  end

  def get_transaction(transaction_id)
    Transaction.all(:id => transaction_id).first
  end

  def get_transaction_by_user_id(user_id, transaction_id)
    Transaction.all(:id => transaction_id, :user_id => user_id).first
  end

  def get_transactions_by_status(status)
    Transaction.all(:status => status)
  end

  def save_transaction(user_id, resource_id, type, amount, currency, confirmation_url)
    Transaction.create(:user_id => user_id,
                                  :resource_id => resource_id,
                                  :amount => amount,
                                  :currency => currency,
                                  :type => type,
                                  :status => 'pending',
                                  :confirmation_url => confirmation_url)
  end

  def confirm_transaction(transaction_id, confirmation_result)
    transaction = get_transaction transaction_id

    raise Exception, "Transaction with id #{transaction_id} not found!" if transaction == nil

    transaction.ledger_id = confirmation_result[:ledger]
    transaction.payment_hash = confirmation_result[:hash]
    transaction.timestamp = confirmation_result[:timestamp]
    transaction.amount = confirmation_result[:amount]
    transaction.currency = confirmation_result[:currency]
    transaction.status = confirmation_result[:status]

    transaction.save

  end
end