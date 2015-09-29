require './api/models/trust'
require './api/repositories/trust_repository'
require './api/constants/error_constants'
require './api/errors/identity_error'

class TrustService
  include ErrorConstants::IdentityErrors

  def initialize(trust_repository = TrustRepository)
    @trust_repository = trust_repository.new
  end

  def create_or_update(domain, aes_key, login_uri)
    raise IdentityError, INVALID_DOMAIN if domain.to_s == ''
    raise IdentityError, INVALID_AES_KEY if aes_key.to_s == ''

    @trust_repository.create_or_update_trust domain, aes_key, login_uri

  end

  def get_all
    @trust_repository.get_all
  end

  def get_by_domain(domain)
    @trust_repository.get_trust domain
  end

  def delete(domain)
    #TODO: delete from the DB - username is the identifier
    raise 'User delete not implemented'
  end

end