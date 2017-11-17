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
end


delete '/api/v1/applications/volunteers/:_id' do
  database[:volunteers].delete_one( {_id: BSON::ObjectId(params[:_id]) } )
  data = []
  database[:volunteers].find.each do |volunteer|
    data << volunteer.to_h
  end
  json data
end
