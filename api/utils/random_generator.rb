require 'securerandom'

module RandomGenerator

  def self.generate_alphanumeric(len)
    len.times.map { [*'0'..'9', *'a'..'z'].sample }.join
    end

  def self.generate_numeric(len)
    len.times.map { [*'0'..'9'].sample }.join
  end

  def self.generate_alpha(len)
    len.times.map { [*'a'..'z'].sample }.join
  end

  def self.generate_uuid
    SecureRandom.uuid
  end

  def self.generate_random_number
    SecureRandom.random_number 500
  end

end