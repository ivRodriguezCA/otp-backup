require 'rbnacl'
require 'base64'

class Device < ApplicationRecord
  belongs_to :user
  has_many :otps

  def decrypted_otps(password)
  	encrypted_master_key = Base64.decode64(self.master_password)

  	# Derive a key from the user's PIN
    salt = Base64.decode64(self.salt)
    opslimit = 2**20
    memlimit = 2**24
    key_size = 32
    device_key = RbNaCl::PasswordHash.scrypt(password, salt, opslimit, memlimit, key_size)

    # Decrypt the master_key with the device_key
    device_box = RbNaCl::SimpleBox.from_secret_key(device_key)
    master_key = device_box.decrypt(encrypted_master_key)

    # Iterate over OTPs and decrypt their secrets
    box = RbNaCl::SimpleBox.from_secret_key(master_key)
    self.otps.map do |otp|
    	secret = Base64.decode64(otp.secret)
    	OpenStruct.new({id: otp.id, account: otp.account, secret: box.decrypt(secret)})
    end
  end
end
