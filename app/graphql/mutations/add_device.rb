require 'rbnacl'
require 'base64'

class Mutations::AddDevice < GraphQL::Function
  argument :name, types.String
  argument :password, types.String

  type do
    name 'AddedDeviceResponse'

    field :id, types.String
    field :name, types.String
  end

  def call(user, args, ctx)
    user = ctx[:current_user]

    if user.blank?
      raise GraphQL::ExecutionError.new("Authentication required")
    end

    d_name = args[:name]
    password = args[:password]
    return unless d_name and password

    # Derive a key from the user's PIN
    salt = RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
    opslimit = 2**20
    memlimit = 2**24
    key_size = 32
    device_key = RbNaCl::PasswordHash.scrypt(password, salt, opslimit, memlimit, key_size)
    
    # Generate a master_key for all the OTPs
    master_key = RbNaCl::Random.random_bytes(key_size)

    # Encrypt the master_key with the device_key
    box = RbNaCl::SimpleBox.from_secret_key(device_key)
    encrypted_master_key = box.encrypt(master_key)

    # Base64 encode the encrypted_master_key and the salt for storage
    encoded_master_key = Base64.encode64(encrypted_master_key)
    encoded_salt = Base64.encode64(salt)

    # Store new device
    device = user.devices.create(name: d_name, master_password:encoded_master_key, salt: encoded_salt)
    return unless device

    OpenStruct.new({id: device.id, name: device.name})
  end
end