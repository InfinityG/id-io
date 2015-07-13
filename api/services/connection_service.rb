require './api/models/connection'
require './api/repositories/connection_repository'
require './api/repositories/user_repository'
require './api/services/identity_service'
require './api/constants/error_constants'
require './api/errors/identity_error'

class ConnectionService
  include ErrorConstants::IdentityErrors

  def initialize(connection_repository = ConnectionRepository, user_repository = UserRepository,
                 identity_service = IdentityService)
    @connection_repository = connection_repository.new
    @user_repository = user_repository.new
    @identity_service = identity_service.new
  end

  def create(current_user, data)
    public_key = current_user.public_key

    target_username = data[:username]
    digest = data[:digest]
    signature = data[:signature]

    # before we do anything we need to confirm the signature
    @identity_service.validate_signature digest, signature, public_key

    # next we need to confirm that the requested user contact exists
    target_user = @user_repository.get_by_username target_username

    if target_user == nil
      raise IdentityError, USER_NOT_FOUND
    end

    # finally, create the contact request
    result = @connection_repository.create current_user, target_user

    {
        :id => result.id,
        :status => result.status,
        :user => {
            :type => 'target',
            :username => target_user.username,
            :first_name => target_user.first_name,
            :last_name => target_user.last_name
        }
    }

  end

  # connection confirmations
  def update(connection_id, current_user, data)
    public_key = current_user.public_key

    digest = data[:digest]
    signature = data[:signature]
    status = data[:status]

    # before we do anything we need to confirm the signature
    @identity_service.validate_signature digest, signature, public_key

    # retrieve the connection
    connection = @connection_repository.get_connection connection_id

    if connection == nil
      raise IdentityError, CONTACT_NOT_FOUND
    end

    # finally, confirm the connection request and update
    connection.status = status
    @connection_repository.update connection

    {
        :id => connection.id,
        :status => connection.status,
        :user => {
            :type => 'origin',
            :user_id => connection.origin_user_id,
            :username => connection.origin_username
        }
    }

  end

  # TODO: refactor this to be more efficient! (may need to refactor user model to embed connections)
  def get_connections(current_user, status)

    # get connections where the current user is either the target OR the origin
    connections = @connection_repository.get_connections current_user.id.to_s, status

    connections_arr = []

    connections.each do |connection|

      connected_user = nil
      connection_type = nil

      # if the current user is the target, show the origin
      if connection.target_user_id == current_user.id.to_s
        connected_user = @user_repository.get_user(connection.origin_user_id)
        connection_type = 'origin'
      end

      # if the current user is the origin, show the target
      if connection.origin_user_id == current_user.id.to_s
        connected_user = @user_repository.get_user(connection.target_user_id)
        connection_type = 'target'
      end

      connections_arr << {
          :id => connection.id,
          :status => connection.status,
          :user => {
              :type => connection_type,
              :username => connected_user.username,
              :first_name => connected_user.first_name,
              :last_name => connected_user.last_name,
              :public_key => connection.status == 'connected' ? connected_user.public_key : nil
          }
      }
    end

    connections_arr
  end

  def get_connection(origin_user_id, target_user_id)
    @connection_repository.get_connection_by_user_id origin_user_id, target_user_id
  end

  def delete(connection)
    raise 'Connection delete not implemented'
  end

end