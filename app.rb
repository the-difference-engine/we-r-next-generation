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
    data=[]
    database[:profiles].find.each do |people|
      data << people.to_h
    end
  json(data)
end

#update 1

# not working yet
put '/api/v1/profile/:profile_id' do


end


get '/api/v1/applications/volunteers' do
  data = []
  database[:volunteers].find.each do |volunteer|
    data << volunteer.to_h
  end
  json data
end



get '/api/v1/applications/volunteers/:_id' do
  json database[:volunteers].find(:_id => BSON::ObjectId(params[:_id])).first
end



post '/api/v1/applications/volunteers' do
  json database[:volunteers].insert_one(params)
end



put '/api/v1/applications/volunteers/:id' do
  database[:volunteers].find(:_id => BSON::ObjectId(params[:_id]))
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
  json database[:camps].insert_one(params)
end

get '/api/v1/applications/camps/:_id' do

  json database[:camps].find(:_id => BSON::ObjectId(params[:_id])).first

end

users = [
  {
    full_name: "Jon Doe",
    'user_id': "1",
    address_1: " 4 Matadi Street",
    address_2: " Plot 8c Metalbox   road, off Acme road",
    town: "Ogba",
    province: "Ikeja lagos",
    zip: "20303",
    country: "Nigeria",
    email: "user@gmail.com",
    phone_number: "555-555-5555",
    password: "xxxxxx",
    profile_img: "url_image"
  },
  {
    full_name: "Kyle Kuhn",
    'user_id': "2",
    address_1: " 4 Matadi Street",
    address_2: " Plot 8c Metalbox   road, off Acme road",
    town: "Ogba",
    province: "Ikeja lagos",
    zip: "20303",
    country: "Nigeria",
    email: "user@gmail.com",
    phone_number: "555-555-5555",
    password: "xxxxxx",
    profile_img: "url_image"
  }

]

get '/api/v1/users/:user_id/profile' do
  users.each do |user_object|
    this_id = user_object['user_id'] || user_object[:user_id]
    if this_id == params['user_id']
      return user_object.to_json
    end
  end
  status 404
end



post '/api/v1/users/:user_id/profile' do
  users << params.to_h
  status 201
  json({})
end








put '/api/v1/applications/camps/:_id' do
  # data = []
  # data << database[:camps].find(:_id => BSON::ObjectId(params[:_id])).update_one(params)
  # json data
end

