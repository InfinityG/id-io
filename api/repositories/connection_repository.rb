require 'mongo_mapper'
require 'bson'
require './api/models/connection'

class ConnectionRepository
  include Mongo
  include MongoMapper
  include BSON
  include SmartIdentity::Models

  def create(origin_user, target_user, status = 'pending')
    # check if the mapping already exists
    contact = get_connection_by_user_id origin_user.id.to_s, target_user.id.to_s

    (contact == nil) ?
        Connection.create(origin_user_id: origin_user.id, origin_username: origin_user.username,
                          target_user_id: target_user.id, target_username: target_user.username,
                          status: status) :
        nil
  end

  def update(connection)
    connection.save
  end

  def get_connection(contact_id)
    Connection.find(contact_id)
  end

  def get_connection_by_user_id(origin_user_id, target_user_id)
    Connection.first(:origin_user_id => origin_user_id, :target_user_id => target_user_id)
  end

  # get connections for a particular user
  def get_connections(origin_user_id, status)
    (status.to_s != '') ?
    #User.where(:$or => [{:private => 1}, {:beta => 0}])
        Connection.where(:$or => [{:origin_user_id => origin_user_id}, {:target_user_id => origin_user_id}], :status => status):
        Connection.where(:$or => [{:origin_user_id => origin_user_id}, {:target_user_id => origin_user_id}])
  end

end