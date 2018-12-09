Types::UserType = GraphQL::ObjectType.define do
  name "User"
  description "A User"
  field :id, types.ID
  field :email, types.String
  field :password, types.String
  field :devices do
    type types[Types::DeviceType]
    resolve -> (user, args, ctx) {
      user.devices
    }
  end
end
