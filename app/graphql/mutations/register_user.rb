class Mutations::RegisterUser < GraphQL::Function
  argument :email, types.String
  argument :password, types.String

  type Types::UserType

  def call(user, args, ctx)
    email = args[:email]
    password = args[:password]
    return unless email && password

    if not User.find_by(email: email).blank?
      raise GraphQL::ExecutionError.new("User already exists.")
    end

    User.create(email: email, password: password)
  end
end