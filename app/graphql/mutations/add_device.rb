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
    return unless user

    d_name = args[:name]
    password = args[:password]
    return unless d_name && password

    salt = RbNaCl::Random.random_bytes(RbNaCl::PasswordHash::SCrypt::SALTBYTES)
    opslimit = 2**20
    memlimit = 2**24
    digest_size = 64
    digest = RbNaCl::PasswordHash.scrypt(password, salt, opslimit, memlimit, digest_size)
    encoded_digest = Base64.encode64(digest)
    print "[debug] encoded_digest= ", encoded_digest, "\n"
    device = user.devices.create(name: d_name, master_password:encoded_digest)
    return unless device

    print "[debug] ", device, "\n"
    OpenStruct.new({id: device.id, name: device.name})
  end
end