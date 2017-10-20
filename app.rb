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

users = [
  {
    full_name: "Jon Doe",
    user_id: "1",
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
    user_id: "2",
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
  # get the id from the params, grab user by id number
  # return json representing all fields of the user onject
  user_id = params[:user_id]
  
  users.each do |user_object|
    this_id = user_object[:user_id]
    if this_id === user_id 

    return user_object.to_json
    end

  end
end



post '/api/v1/users/:user_id/profile' do
user_id = params[:user_id]
  
  users.each do |user_object|
    this_id = user_object[:user_id]
    if this_id === user_id 

    return user_object.to_json
    end

  end
end





# get '/api/v1/applications/volunteers'

# post '/api/v1/applications/volunteers'
