Inputs::SignInInput = GraphQL::InputObjectType.define do
  name 'SignInInput'
  description 'An input object representing arguments for a sign in call'

  argument :email, types.String, "Email"
  argument :password, types.String, "Password"
end