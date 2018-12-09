Rails.application.routes.draw do
  post '/graphql' => 'application#execute'
end
