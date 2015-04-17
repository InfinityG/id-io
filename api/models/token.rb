module SmartIdentity
  module Models
    class Token
      include MongoMapper::Document

      key :user_id, String
      key :uuid, String,  :key => true
      key :expires, Integer
      key :ip_address, String
    end
  end
end