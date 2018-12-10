require 'rbnacl'
require 'base64'

class Mutations::AddOtp < GraphQL::Function
  argument :account, types.String
  argument :secret, types.String
  argument :device_id, types.Int
  argument :password, types.String

  type do
    name 'AddedOTPResponse'

    field :id, types.String
    field :account, types.String
  end

  def call(user, args, ctx)
    user = ctx[:current_user]

    if user.blank?
      raise GraphQL::ExecutionError.new("Authentication required.")
    end

    account = args[:account]
    secret = args[:secret]
    device_id = args[:device_id]
    password = args[:password]
    if not account or not secret or not password
      raise GraphQL::ExecutionError.new("Missing parameters.")
    end

    device = Device.find_by(id: device_id)
    if not device
      raise GraphQL::ExecutionError.new("Missing device.")
    end

    # Derive a key from the user's PIN
    salt = Base64.decode64(device.salt)
    opslimit = 2**20
    memlimit = 2**24
    key_size = 32
    device_key = RbNaCl::PasswordHash.scrypt(password, salt, opslimit, memlimit, key_size)

    # Decrypt master_key
    device_box = RbNaCl::SimpleBox.from_secret_key(device_key)
    encoded_master_key = Base64.decode64(device.master_password)
    master_key = device_box.decrypt(encoded_master_key)

    # Encrypt OTP secret with master_key
    box = RbNaCl::SimpleBox.from_secret_key(master_key)
    ciphertext = box.encrypt(secret)
    encoded_ciphertext = Base64.encode64(ciphertext)

    # Store the OTP
    otp = device.otps.create(account: account, secret: encoded_ciphertext)
    return unless otp

    OpenStruct.new({id: otp.id, account: otp.account})
  end
end