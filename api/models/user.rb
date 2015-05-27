module SmartIdentity
  module Models
    class User
      include MongoMapper::Document

      key :first_name, String, :required => true
      key :last_name, String, :required => true
      key :username, String, :required => true, :key => true
      key :password_hash, String
      key :password_salt, String
      key :public_key, String
      key :block_confirmed, Boolean
      key :block_create_hash, String
      key :mobile_number, String
      key :mobile_confirmed, Boolean
      key :id_docs_confirmed, Boolean
      key :role, String
      key :registrar, String

      many :webhooks, :class_name => 'SmartIdentity::Models::Webhook'
    end
  end
end