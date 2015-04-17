module SmartIdentity
  module Models
    class Challenge
      include MongoMapper::Document

      key :username, String
      key :data, String,  :key => true
      key :expires, Integer
    end
  end
end