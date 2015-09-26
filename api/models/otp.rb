module SmartIdentity
  module Models
    class Otp
      include MongoMapper::Document

      key :username, String
      key :pin, String
      key :nonce, String
      key :expires, Integer
      key :status, String

      timestamps!
    end
  end
end