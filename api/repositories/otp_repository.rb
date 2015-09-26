require 'mongo_mapper'
require 'bson'
require './api/models/otp'

class OtpRepository
  include Mongo
  include MongoMapper
  include BSON
  include SmartIdentity::Models

  def get_otp_by_username(username)
    Otp.where(:username => username).first
  end

  def get_otp_by_nonce(uuid)
    Otp.where(:nonce => uuid).first
  end

  def create_otp(username, pin, nonce, expires)
    Otp.create(:username => username, :pin => pin, :nonce => nonce, :expires => expires)
  end

  def update_otp_status(status, otp)
    otp.status = status
    otp.save
  end

  def delete_otp(id)
    Otp.destroy(id)
  end

end