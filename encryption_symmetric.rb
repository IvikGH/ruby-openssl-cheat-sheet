# Symmetric crypto lets you scramble some data with one shared key. It is faster
# than asymmetric crypto, but has the downside that you can only share the data
# with trusted parties, so the key has to be pre-shared somehow, unlike asymmetric
# crypto.
#
# Note that a common method for fast cryptography is to first connect with the
# slower asymmetric crypto, then use that connection to exchange a shared secret
# for symmetric crypto. HTTPS and SSL sockets use this method. This means you get
# the full additional security from asymmetric crypto, but the speed of symmetric
# crypto.

require "openssl"

secret = "fd5d148867091d7595c388ac0dc50bb465052b764c4db8b4b4c3448b52ee0b33df16975830acca82"
data = "This is some data"

# You can list available chiphers.
#p OpenSSL::Cipher.ciphers

# The chiphers take the format name-keylength-mode
cipher = OpenSSL::Cipher.new("AES-128-CBC")

# An alternative way of creating the object would be
cipher = OpenSSL::Cipher::AES.new(128, :CBC)

# The API is very imperative, as it binds pretty directly to the underlying C
# libraries. This call sets the object in encryption mode.
cipher.encrypt

cipher.key = secret

# Many ciphers uses an initialization vector (IV) to randomize encryption. IVs should be unpredictable.
# See Ruby docs for more info: http://ruby-doc.org/stdlib-2.2.0/libdoc/openssl/rdoc/OpenSSL/Cipher.html#class-OpenSSL::Cipher-label-Choosing+an+IV
iv = cipher.random_iv

encrypted = cipher.update(data) + cipher.final
p iv + encrypted
# => ...some unreadable binary stuff...

# Time to decrypt it. We need to create a new object.
decipher = OpenSSL::Cipher::AES.new(128, :CBC)
decipher.decrypt
decipher.key = secret
decipher.iv = encrypted[0..16] # In some modes like CTR you wouldn't be able to decrypt without proper IV setup

decrypted = decipher.update(encrypted[16..-1]) + decipher.final
p decrypted
# => "This is some data"
