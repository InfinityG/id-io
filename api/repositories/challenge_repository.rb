require 'mongo_mapper'
require 'bson'
require './api/models/challenge'

class ChallengeRepository
  include Mongo
  include MongoMapper
  include BSON
  include SmartIdentity::Models

  def create_challenge(username, uuid, expires)
    Challenge.create(username:username, data:uuid, expires: expires)
  end

  def get_challenge(username)
    Challenge.first(:username => username)
  end

  def delete_for_user(username)
    Challenge.destroy_all(:username => username)
  end

end