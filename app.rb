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

put '/api/v1/applications/camps/:_id' do
id_number = params.delete("_id")

json database[:camps].update_one( { '_id' => BSON::ObjectId(id_number) },   { '$set' => params})

end

delete '/api/v1/applications/camps/:_id' do

 database[:camps].delete_one( {_id: BSON::ObjectId(params[:_id]) } )

end
