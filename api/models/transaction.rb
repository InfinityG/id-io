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

      # a special version value for preventing contention
      key :doc_version, Integer

      timestamps!

    end
  end
end