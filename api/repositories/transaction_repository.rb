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
                       :confirmation_url => confirmation_url,
                       :doc_version => 1)
  end

  # 1. As there may be more than one instance of ID-IO running, we need to make sure that different threads
  #     are only able to update a record if it hasn't changed since it was read by that thread (OPTIMISTIC LOCKING).
  #     Use "set"for this, where the first argument is the condition (a hash of the field values that must be satisfied
  #     before the update succeeds). If the condition is not met, the update simply returns nil.
  #   See https://gist.github.com/wxmn/665675 for an example of using "set"

  # 2. In terms of simultaneous writes on a single record, MongoDB uses a readers-writer lock. This means that multiple readers can
  #     access a collection or single document, but only one writer can access a document at any one time.
  #   See http://stackoverflow.com/questions/17456671/to-what-level-does-mongodb-lock-on-writes-or-what-does-it-mean-by-per-connec for
  #   description of readers-writer latch on MongoDB

  def confirm_transaction(transaction, confirmation_result)

    id = transaction.id.to_s
    doc_version = transaction.doc_version

    Transaction.set({:id => id, :doc_version => doc_version},
                    :doc_version => doc_version.to_i + 1,
                    :ledger_id => confirmation_result[:ledger],
                    :payment_hash => confirmation_result[:hash],
                    :timestamp => confirmation_result[:timestamp],
                    :amount => confirmation_result[:amount],
                    :currency => confirmation_result[:currency],
                    :status => confirmation_result[:status])
  end
end