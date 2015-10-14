module SmartIdentity
  module Models
    class User
      include MongoMapper::Document

      key :first_name, String, :required => true
      key :last_name, String, :required => true
      key :username, String, :required => true, :key => true
      key :username_hash, String
      key :password_hash, String
      key :password_salt, String
      key :public_key, String
      key :email, String
      key :email_confirmed, Boolean
      key :mobile_number, String
      key :mobile_confirmed, Boolean
      key :role, String
      key :registrar, String
      key :meta, String

      key :block_status, String

      # a special version value for preventing contention
      key :doc_version, Integer

      many :webhooks, :class_name => 'SmartIdentity::Models::Webhook'

      timestamps!
    end
  end
end