require 'minitest'
require 'minitest/autorun'
require 'base64'

require_relative '../../api/validators/identity_validator'

class ValidationTests < MiniTest::Test

  def test_public_key_validates
    #key is base64 encoded
    public_key = 'Ag7PunGy2BmnAi+PGE4/Dm9nCg1URv8wLZwSOggyfmAn'

    validator = IdentityValidator.new
    result = validator.validate_public_ecdsa_key public_key

    assert result
  end
end