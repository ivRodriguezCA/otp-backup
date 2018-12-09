Types::QueryType = GraphQL::ObjectType.define do
    name "Query"
    description "The query root for this schema"
    
    field :otps do
      type types[Types::OtpType]
      resolve -> (obj, args, ctx) {
        Otp.all
      }
    end

    field :devices do
      type types[Types::DeviceType]
      resolve -> (obj, args, ctx) {
        Device.all
      }
    end

    field :users do
      type types[Types::UserType]
      resolve -> (obj, args, ctx) {
        User.all
      }
    end
end