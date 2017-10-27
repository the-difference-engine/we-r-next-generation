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

# db = File.read("./db/data")
db = {
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
    },
    {
      full_name: "Victor Lee2",
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
}

get '/api/v1/applications/volunteers' do

  data = {}
  data[:data] = db[:volunteers]
  json data
end


post '/api/v1/applications/volunteers' do
  db[:volunteers] << params
  json db
end
