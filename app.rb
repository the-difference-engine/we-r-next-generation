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

get '/api/v1/applications/volunteers' do

{
  volunteers: [
    {
    full_name: "Victor Lee",
    email: "vlee@gmail.com",
    address: "1 Chicago Ave",
    phone_number: "312-345-6655",
    bio: "Hey",
    signature: "VL",
    camp_id: "1",
    status: "Active",
    user_id: 1
    }
  ]
}.to_json
end


post '/api/v1/applications/volunteers' do

{
  full_name: "Natale Anfuso",
  email: "nanfuso@gmail.com",
  address: "3 Clark St",
  phone_number: "312-995-5832",
  bio: "Hi",
  signature: "NA",
  camp_id: "2",
  status: "Active",
  user_id: 2
}.to_json

end
