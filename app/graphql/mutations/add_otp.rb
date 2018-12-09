require 'rbnacl'
require 'base64'

class Mutations::AddOtp < GraphQL::Function
  argument :account, types.String
  argument :secret, types.String
  argument :device_id, types.Int

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
    if not account or not secret
      raise GraphQL::ExecutionError.new("Missing parameters.")
    end

    device = Device.find_by(id: device_id)
    if not device
      raise GraphQL::ExecutionError.new("Missing device.")
    end

    box = RbNaCl::SimpleBox.from_secret_key(Base64.decode64(device.master_password))
    ciphertext = box.encrypt(secret)
    encoded_ciphertext = Base64.encode64(ciphertext)
    otp = device.otps.create(account: account, secret: encoded_ciphertext)
    return unless otp

    OpenStruct.new({id: otp.id, account: otp.account})
  end
end