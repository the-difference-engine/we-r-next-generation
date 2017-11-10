# app.rb

require 'sinatra'
require 'sinatra/json'
require 'rack'
require 'rack/contrib'
require 'mongo'

use Rack::PostBodyContentTypeParser
# Set MONGODB_URL
database = Mongo::Client.new(ENV["MONGODB_URL"])

get '/api/v1/hello' do
  json({msg: 'hello world!'})
end

post '/api/v1/hello' do
  name = params[:name]
  record = {msg: "hello #{name}!"}
  database[:bob].insert_one(record)
  json(record)
end

# vol_app_id = 1
# camp_app_id = 1
#
# db = {
#   profiles: [
#     {
#       "full_name": "Kyle Kuhn",
#       "email": "kisle.kuhn1@gmail.com",
#       "address": "215 Ohio Ave",
#       "phone_number": "111-222-3344",
#       "signature": "KK",
#       "camp_id": "1",
#       "status": "Active"
#
#     },
#     {
#       "full_name": "joe Kuhn",
#       "email": "kisle.kuhn1@gmail.com",
#       "address": "215 Ohio Ave",
#       "phone_number": "111-222-3344",
#       "signature": "KK",
#       "camp_id": "1",
#       "status": "Active",
#       "profile_id": 10
#
#     }
#   ],
#   volunteers: [
#     {
#       full_name: "Victor Lee",
#       email: "vlee@gmail.com",
#       address: "1 Chicago Ave",
#       phone_number: "312-345-6655",
#       bio: "Hey",
#       signature: "VL",
#       camp_id: "1",
#       status: "Active",
#       user_id: 1
#     },
#     {
#       full_name: "Victor Lee2",
#       email: "vlee@gmail.com",
#       address: "1 Chicago Ave",
#       phone_number: "312-345-6655",
#       bio: "Hey",
#       signature: "VL",
#       camp_id: "1",
#       status: "Active",
#       user_id: 1
#     }
#   ]
# }
#
# # get 1
# get '/api/v1/profile/:profile_id' do
#   db[:profiles].each do |profile|
#     if profile[:profile_id] == params[:profile_id].to_i
#       return profile.to_json
#     end
#   end
# end
#
#
#
# # post new
# profile_cnter = 0
# post '/api/v1/profile/:profile_id' do
#   profile_cnter += 1
#   params[:profile_id] = profile_cnter
#   db[:profiles] << params
#   json db
# end
#
# # get all
# get '/api/v1/profile' do
#   data = {}
#   data[:data] = db[:profiles]
#   json data
# end
#
# #update 1
#
# # not working yet
# put '/api/v1/profile/:profile_id' do
#
#
# end

# Volunteer Applications

get '/api/v1/applications/volunteers' do
  data = []
  database[:volunteers].find.each do |volunteer|
    data << volunteer.to_h
  end
  json data
end



get '/api/v1/applications/volunteers/:_id' do
  data = []
  database[:volunteers].find(:_id => BSON::ObjectId(params[:_id])).each do |volunteer|
    data << volunteer.to_h
  end
  json data
end



post '/api/v1/applications/volunteers' do
  database[:volunteers].insert_one(params)
  data = {}
  data[:data] = db[:volunteers].to_h
  json data
end



put '/api/v1/applications/volunteers/:id' do

end

# Camp Applications

# get '/api/v1/applications/camps' do
#   data = {}
#   data[:data] = db[:camps]
#   json data
# end
#
# post '/api/v1/applications/camps' do
#   db[:camps] << params
#   db[:camps][-1][:camp_app_id] = camp_app_id
#   camp_app_id += 1
#   data = {}
#   data[:data] = db[:camps]
#   json data
# end
#
# get '/api/v1/applications/camps/:id' do
#   camp = params[:id].to_i
#   data = {}
#   data[:data] = db[:camps][camp]
#   json data
# end
#
