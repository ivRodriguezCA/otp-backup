Types::DeviceType = GraphQL::ObjectType.define do
    name "Device"
    description "A Device"
    field :id, types.ID
    field :name, types.String
    field :master_password, types.String
    field :otps do
      type types[Types::OtpType]
      resolve -> (device, args, ctx) {
        device.otps
      }
    end
    field :user do
      type Types::UserType
      resolve -> (device, args, ctx) {
        device.user
      }
    end
end