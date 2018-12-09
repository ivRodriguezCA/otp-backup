class Mutations::SignInUser < GraphQL::Function
  argument :email, types.String
  argument :password, types.String

  type Types::UserType

  type do
    name 'SigninUser'

    field :token, types.String
    field :user, Types::UserType
  end

  def call(user, args, ctx)
    email = args[:email]
    password = args[:password]
    return unless email && password

    user = User.find_by(email: email)
    return unless user
    return unless user.authenticate(password)

    token = AuthToken.token_for_user(user)
    ctx[:session][:token] = token

    OpenStruct.new({token: token, user: user})
  end
end