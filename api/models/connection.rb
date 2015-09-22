# a mapping class to handle user > user associations

module SmartIdentity
  module Models
    class Connection
      include MongoMapper::Document

      key :origin_user_id, String, :required => true
      key :origin_username, String, :required => true
      key :target_user_id, String, :required => true
      key :target_username, String, :required => true
      # key :confirmed, Boolean
      key :status, String, :required => true

    end
  end
end