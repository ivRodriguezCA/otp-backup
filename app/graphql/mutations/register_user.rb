class Mutations::RegisterUser < GraphQL::Function
  argument :email, types.String
  argument :password, types.String

  type Types::UserType

  def call(user, args, ctx)
    email = args[:email]
    password = args[:password]
    return unless email && password

    return nil if User.find_by(email: email)

    User.create(email: email, password: password)
  end
end