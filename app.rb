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



db = {
  profiles: [
    {
      "full_name": "Kyle Kuhn",
      "email": "kisle.kuhn1@gmail.com",
      "address": "215 Ohio Ave",
      "phone_number": "111-222-3344",
      "signature": "KK",
      "camp_id": "1",
      "status": "Active"

    },
    {
      "full_name": "joe Kuhn",
      "email": "kisle.kuhn1@gmail.com",
      "address": "215 Ohio Ave",
      "phone_number": "111-222-3344",
      "signature": "KK",
      "camp_id": "1",
      "status": "Active",
      "profile_id": 10

    }
    ],

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


# get 1
get '/api/v1/profile/:profile_id' do
  db[:profiles].each do |profile|
    if profile[:profile_id] == params[:profile_id].to_i
      return profile.to_json
    end
  end
end



# post new
profile_cnter = 0
post '/api/v1/profile/:profile_id' do
  profile_cnter += 1
  params[:profile_id] = profile_cnter
  db[:profiles] << params
  json db
end

# get all
get '/api/v1/profile' do

  data = {}
  data[:data] = db[:profiles]
  json data
end

#update 1

# not working yet
put '/api/v1/profile/:profile_id' do
  db[:profiles].each do |profile|
    if profile[:profile_id] == params[:profile_id].to_i
      db[:profiles] << params
      return profile.to_json
    end
  end

end


get '/api/v1/applications/volunteers' do

  data = {}
  data[:data] = db[:volunteers]
  json data
end


post '/api/v1/applications/volunteers' do
  db[:volunteers] << params
  json db
end
