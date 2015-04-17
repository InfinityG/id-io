require 'ig-crypto-utils'

class SignatureService

  def initialize(ecdsa_util = CryptoUtils::EcdsaUtil)
    @ecdsa_util = ecdsa_util.new
  end

  def sign(data, private_key)
    @ecdsa_util.sign data, private_key
  end

  def create_key_pair
    @ecdsa_util.create_key_pair
  end

  def validate_signature(digest, signature, public_key)
    @ecdsa_util.validate_signature(digest, signature, public_key)
  end

end