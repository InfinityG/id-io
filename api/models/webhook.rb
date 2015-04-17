module SmartIdentity
  module Models
    class Webhook
      include MongoMapper::EmbeddedDocument

      key :uri, String
      key :headers, Array
      key :body, String
    end
  end
end