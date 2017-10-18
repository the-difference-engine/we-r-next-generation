# app.rb

require 'sinatra'
require 'sinatra/json'

get '/api/v1/hello' do
  json({msg: 'hello world!'})
end
