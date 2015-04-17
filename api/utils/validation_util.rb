class ValidationUtil
  def self.validate_string(value)
    value.to_s != ''
  end

  def self.validate_integer(value)
    Float(value) != nil rescue false
  end

  def self.validate_uuid(value)
    value =~ /^[0-9a-f]{8}-[0-9a-f]{4}-[1-5][0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i
  end

  def self.validate_hex(value)
    value =~ /^[a-f\d]{24}$/i
  end

  # At least one upper case english letter
  # At least one lower case english letter
  # At least one digit
  # At least one special character
  # Minimum 8 in length
  def self.validate_password(value)
    value =~ /^(?=^.{8,}$)(?=.*\d)(?![.\n])(?=.*[A-Z])(?=.*[a-z]).*$/i
  end

  # for a 256-bit ECDSA curve, the uncompressed pubkey is 512 bits (256 bits of x, 256 bits of y, no sign bit).
  # the compressed pubkey is 257 bits (256 bits of x, one bit of the sign of y).
  # this equates to 32 bytes (ie: 256/8 = 32) + 1 (the sign) = 33
  def self.validate_public_ecdsa_key(value)
    decoded_key = Base64.decode64 value
    decoded_key.length == 33
  end

  def self.validate_unix_datetime(value)
    begin
      now = Date.today.to_time
      time_to_validate = Time.at value
      return time_to_validate > now
    rescue
      return false
    end
  end
end