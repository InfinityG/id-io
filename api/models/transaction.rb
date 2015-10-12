module SmartIdentity
  module Models
    class Transaction

      include MongoMapper::Document

      key :confirmation_url, String
      key :user_id, String
      key :resource_id, String
      key :ledger_id, Integer
      key :payment_hash, String
      key :timestamp, String
      key :amount, String
      key :currency, String
      key :type, String
      key :status, String

    end
  end
end