# app.rb

require 'sinatra'
require 'sinatra/json'
require 'rack'
require 'rack/contrib'

use Rack::PostBodyContentTypeParser

get '/api/v1/hello' do
  json({msg: 'hello world!'})
end

post '/api/v1/hello' do
  name = params[:name]
  json({msg: "hello #{name}!"})
end


# get '/api/v1/users/:user_id/profile'

# post '/api/v1/users/:user_id/profile'

# get '/api/v1/applications/volunteers'

# post '/api/v1/applications/volunteers'
