require 'mongo_mapper'
require 'bson'
require './api/models/trust'

class TrustRepository
  include Mongo
  include MongoMapper
  include BSON
  include SmartIdentity::Models

  def create_or_update_trust(domain, aes_key, login_uri)
    Trust.destroy_all(:domain => domain) if (get_trust(domain) != nil)
    Trust.create(domain: domain, aes_key: aes_key, :login_uri => login_uri)
  end

  def get_trust(domain)
    Trust.first(:domain => domain)
  end

  def get_all_trusts
    Trust.all
  end
end