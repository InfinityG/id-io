module SmartIdentity
  module Models
    class Trust
      include MongoMapper::Document

      key :domain, String
      key :aes_key, String
    end
  end
end