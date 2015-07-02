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
    digest = data[:data]
    signature = data[:signature]

    # before we do anything we need to confirm the signature
    @identity_service.validate_signature digest, signature, public_key

    # next we need to confirm that the requested user contact exists
    target_user = @user_repository.get_by_username target_username

    if target_user == nil
      raise IdentityError, USER_NOT_FOUND
    end

    # finally, create the contact request
    @connection_repository.create current_user, target_user

  end

  def update(connection_id, current_user, data)
    public_key = current_user.public_key

    digest = data[:data]
    signature = data[:signature]

    # before we do anything we need to confirm the signature
    @identity_service.validate_signature digest, signature, public_key

    # retrieve the connection
    connection = @connection_repository.get_connection connection_id

    if connection == nil
      raise IdentityError, CONTACT_NOT_FOUND
    end

    # finally, confirm the connection request and update
    connection.confirmed = true
    @connection_repository.update connection
    connection
  end

  def get_connections(origin_user_id, confirmed)
    @connection_repository.get_connections origin_user_id, confirmed
  end

  def get_connection(origin_user_id, target_user_id)
    @connection_repository.get_connection_by_user_id origin_user_id, target_user_id
  end

  def delete(domain)
    raise 'Connection delete not implemented'
  end

end