require 'securerandom'
require 'digest'
require './api/utils/random_generator'

module HashGenerator

  def self.generate_password_hash(password, salt)
    salted_password = password + salt
    generate_hash salted_password
  end

  def self.generate_hash(data)
    Digest::SHA2.base64digest data
  end

  def self.generate_salt
    RandomGenerator.generate_uuid
  end
end