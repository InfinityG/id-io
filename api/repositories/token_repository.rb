require 'mongo_mapper'
require 'bson'
require './api/models/token'

class TokenRepository
  include Mongo
  include MongoMapper
  include BSON
  include SmartIdentity::Models

  def get_token(uuid)
    Token.where(:uuid => uuid).first
  end

  def save_token(user_id, uuid, fingerprint, expires)
    # remove previous tokens, if any
    Token.destroy_all(:user_id => user_id)
    # create a single new one - this ensures that only 1 token can ever be in use by a single user at any time
    Token.create(:user_id => user_id.to_s, :uuid => uuid, :fingerprint => fingerprint, :expires => expires)
  end

  def delete_token(id)
    Token.destroy(id)
  end
end