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

# Volunteer Applications


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




# Profiles Applications
# post new
profile_cnter = 0
post '/api/v1/profiles' do
  json database[:profiles].insert_one(params)
end

get '/api/v1/profiles/:profile_id' do
  profile_id = params[:profile_id]
  obj_id = BSON::ObjectId(profile_id)
  profile_table = database[:profiles]
  query_reults = profile_table.find(:_id => obj_id)
  match = query_reults.first
  json(match.to_h)

end

# get all
get '/api/v1/profiles' do
    data=[]
    database[:profiles].find.each do |people|
      data << people.to_h
    end
  json(data)
end

put '/api/v1/profiles/:id' do
  idnumber = params.delete("id")
  json database[:profiles].update_one(
    {'_id' => BSON::ObjectId(idnumber)}, {'$set' => params }
  )
end

delete '/api/v1/profiles/:_id' do

  database[:profiles].delete_one( {_id: BSON::ObjectId(params[:_id]) } )

end




# Volunteer Applications
#update 1


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
  idnumber = params.delete("id")
  json database[:volunteers].update_one(
    {'_id' => BSON::ObjectId(idnumber)}, {'$set' => params }
    )
  # json database[:volunteers].find(:_id => BSON::ObjectId(idnumber)).first
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

put '/api/v1/applications/camps/:_id' do
id_number = params.delete("_id")

json database[:camps].update_one( { '_id' => BSON::ObjectId(id_number) },   { '$set' => params})

end

delete '/api/v1/applications/camps/:_id' do

 database[:camps].delete_one( {_id: BSON::ObjectId(params[:_id]) } )

end
