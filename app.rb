# app.rb

require 'sinatra'
require 'sinatra/json'
require 'rack'
require 'rack/contrib'
require 'mongo'

use Rack::PostBodyContentTypeParser
# Set MONGODB_URL
database = Mongo::Client.new(ENV["MONGODB_URL"])
# puts database.collection_names
get '/api/v1/hello' do
  json({msg: 'hello world!'})
end

post '/api/v1/hello' do
  name = params[:name]
  record = {msg: "hello #{name}!"}
  database[:bob].insert_one(record)
  json(record)
end

vol_app_id = 1
camp_app_id = 1

old_database = {
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

# Volunteer Applications


# get 1
get '/api/v1/profile/:profile_id' do
  old_database[:profiles].each do |profile|
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
  old_database[:profiles] << params
  json old_database
end

# get all
get '/api/v1/profile' do
  data = {}
  data[:data] = old_database[:profiles]
  json data
end

#update 1

# not working yet
put '/api/v1/profile/:profile_id' do


end


get '/api/v1/applications/volunteers' do
  data = {}
  data[:data] = old_database[:volunteers]
  json data
end


post '/api/v1/applications/volunteers' do
  old_database[:volunteers] << params
  old_database[:volunteers][-1][:volunteer_id] = vol_app_id
  vol_app_id += 1
  data = {}
  data[:data] = old_database[:volunteers]
  json data
end

get '/api/v1/applications/volunteers/:id' do
    old_database[:volunteers].each do |volun|
      if volun[:volunteer_id] == params[:id].to_i
        data = {}
        data[:data] = volun
        return data.to_json
      end
    end
end

put '/api/v1/applications/volunteers/:id' do

end

# Camp Applications

get '/api/v1/applications/camps' do
  data = []
  database[:camps].find.each do |document|

    data << document.to_h
  end
  json data
end

post '/api/v1/applications/camps' do

  # database[:camps] << params
  # data = {}
  # data[:data] = database[:camps]
  # old_database[:camps] << params
  # old_database[:camps][-1][:camp_app_id] = camp_app_id
  # camp_app_id += 1
  # data = {}
  # data[:data] = old_database[:camps]
  # json database
end


get '/api/v1/applications/camps/:_id' do
  data = []
  database[:camps].find(:_id => BSON::ObjectId(params[:_id])).each do |document|
    data << document.to_h
  end
  json data
end

