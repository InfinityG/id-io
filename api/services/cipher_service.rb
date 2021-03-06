require 'ig-crypto-utils'

# symmetric encryption functions

class CipherService

  def initialize(aes_util = CryptoUtils::AesUtil)
    @aes_util = aes_util.new
  end

  def aes_encrypt(data, aes_key)
   @aes_util.encrypt(data, aes_key)
  end

end