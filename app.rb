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

v_id = 1

db = {
  volunteers: [
    # {
    #   full_name: "Victor Lee",
    #   email: "vlee@gmail.com",
    #   address: "1 Chicago Ave",
    #   phone_number: "312-345-6655",
    #   bio: "Hey",
    #   signature: "VL",
    #   camp_id: "1",
    #   status: "Active"
    # },
    # {
    #   full_name: "Victor Lee2",
    #   email: "vlee@gmail.com",
    #   address: "1 Chicago Ave",
    #   phone_number: "312-345-6655",
    #   bio: "Hey",
    #   signature: "VL",
    #   camp_id: "1",
    #   status: "Active"
    # }
  ],
  camps: [
    {
      parent_name: "Michael Lee",
      email: "mlee@gmail.com",
      address: "321 Park Blvd",
      phone_number: "886-229-5088",
      child_name: "Harry Lee",
      child_age: 1,
      camp_id: 1,
      benefit: "Harry can be the next Picasso",
      signature: "Michael Lee",
      app_id: 1
    },
    {
      parent_name: "Michael Hwang",
      email: "mhwang@gmail.com",
      address: "322 S Michgan Ave",
      phone_number: "630-839-3109",
      child_name: "Evan Hwang",
      child_age: 1,
      camp_id: 2,
      benefit: "Evan can be the next Jeremy Lin",
      signature: "Michael Hwang",
      app_id: 2
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
  db[:volunteers][-1][:volunteer_id] = v_id
  v_id += 1
  data = {}
  data[:data] = db[:volunteers]
  json data
end

get '/api/v1/applications/volunteers/:id' do
  v = params[:id].to_i
    db[:volunteers].each do |volunteer|
      if volunteer[:volunteer_id] == v
        return volunteer.to_json
      end
    end
end

get '/api/v1/applications/camps' do
  data = {}
  data[:data] = db[:camps]
  json data
end

post '/api/v1/applications/camps' do
  db[:camps] << params
  json db
end

get '/api/v1/applications/camps/:id' do
  camp = params[:id].to_i
  data = {}
  data[:data] = db[:camps][camp]
  json data
end

