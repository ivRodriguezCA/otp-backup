Types::MutationType = GraphQL::ObjectType.define do
	name "Mutation"

	field :signInUser, function: Mutations::SignInUser.new
	field :registerUser, function: Mutations::RegisterUser.new
	field :addDevice, function: Mutations::AddDevice.new
	field :addOtp, function: Mutations::AddOtp.new
end
