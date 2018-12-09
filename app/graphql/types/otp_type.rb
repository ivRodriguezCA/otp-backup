Types::OtpType = GraphQL::ObjectType.define do
  name "Otp"
  description "A One-time Password"
  field :id, types.ID
  field :account, types.String
  field :secret, types.String
  field :device do
    type Types::UserType
    resolve -> (otp, args, ctx) {
      otp.device
    }
  end
end
