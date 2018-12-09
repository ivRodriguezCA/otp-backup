class ApplicationController < ActionController::API
	def execute
		variables = ensure_hash(params[:variables])
		query = params[:query]
		context = {
			current_user: current_user,
			session: session
		}
		result = OtpBackupSchema.execute(query, variables: variables, context: context)
		render json: result
	end
end

private

# Handle form data, JSON body, or a blank value
def ensure_hash(ambiguous_param)
	case ambiguous_param
	when String
		if ambiguous_param.present?
			ensure_hash(JSON.parse(ambiguous_param))
		else
			{}
		end
	when Hash, ActionController::Parameters
		ambiguous_param
	when nil
		{}
	else
		raise ArgumentError, "Unexpected parameter: #{ambiguous_param}"
	end
end

def current_user
	return nil if request.headers['Authorization'].blank?
	
	token = request.headers['Authorization'].split(' ').last
	return nil if token.blank?
	
	AuthToken.user_from_token(token)
end