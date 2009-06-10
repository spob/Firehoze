require 'openssl'
require 'digest/sha2'
require 'base64'

module ActiveUrl
  module Crypto
    CipherError = OpenSSL::Cipher.const_defined?(:CipherError) ? OpenSSL::Cipher::CipherError : OpenSSL::CipherError
    
    PADDING = { 2 => "==", 3 => "=" }
 
    def self.encrypt(clear)
      crypto = start(:encrypt)
      cipher = crypto.update(clear)
      cipher << crypto.final
      Base64.encode64(cipher).gsub(/[\s=]+/, "").gsub("+", "-").gsub("/", "_")
    end
 
    def self.decrypt(b64)
      cipher = Base64.decode64("#{b64.gsub("-", "+").gsub("_", "/")}#{PADDING[b64.length % 4]}")
      crypto = start(:decrypt)
      clear = crypto.update(cipher)
      clear << crypto.final
    end
 
    private
 
    def self.start(mode)
      raise ::ArgumentError.new("Set a secret key using ActiveUrl::Config.secret = 'your-secret'") if ActiveUrl::Config.secret.blank?
      crypto = OpenSSL::Cipher::Cipher.new('aes-256-ecb').send(mode)
      crypto.key = Digest::SHA256.hexdigest(ActiveUrl::Config.secret)
      return crypto
    end
  end
end