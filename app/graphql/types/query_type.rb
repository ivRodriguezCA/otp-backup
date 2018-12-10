Types::QueryType = GraphQL::ObjectType.define do
    name "Query"
    description "The query root for this schema"
    
    field :otps do
      argument :device_id, !types.Int
      argument :password, !types.String

      type types[Types::OtpType]
      resolve -> (obj, args, ctx) {
        if ctx[:current_user].blank?
          raise GraphQL::ExecutionError.new("Authentication required.")
        end

        device_id = args[:device_id]
        device = Device.find_by(id: device_id)
        if not device
          raise GraphQL::ExecutionError.new("Unknown device.")
        end

        device.decrypted_otps(args[:password])
      }
    end

    field :devices do
      type types[Types::DeviceType]

      resolve -> (obj, args, ctx) {
        user = ctx[:current_user]
        user.devices
      }
    end
end