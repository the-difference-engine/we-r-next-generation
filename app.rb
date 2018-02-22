# app.rb

require 'sinatra'
require 'sinatra/json'
require 'rack'
require 'rack/contrib'
require_relative 'validate'
require_relative 'emailUtils'
require 'mongo'
require 'sinatra/cors'

use Rack::PostBodyContentTypeParser
# Set MONGODB_URL
database = Mongo::Client.new(ENV["MONGODB_URL"])

set :allow_origin, "*"
set :allow_methods, "GET,HEAD,POST,DELETE"
set :allow_headers, "content-type,if-modified-since, x-token"
set :expose_headers, "location,link"

postWhitelist = ['sessions', 'faq']
getWhitelist = ['resources', 'faq', 'campinfo']
before '*' do

  if (postWhitelist.any? { |value| request.path_info.include? '/api/v1/' + value}) && (request.request_method == "POST")
    next

  elsif (getWhitelist.any? { |value| request.path_info.include? '/api/v1/' + value}) && (request.request_method == "GET")
    next

  elsif request.request_method == "OPTIONS"
    next

  else
    collection = database[:sessions]
    @token = request.env['HTTP_X_TOKEN']

    if !@token
      halt(401, "Invalid Token")
    elsif !BSON::ObjectId.legal?(@token)
      halt(401, "Invalid Token")
    else
      session = collection.find( {:_id => BSON::ObjectId(@token) }).first
      if session.nil?
        halt(401, "Invalid Token")
      else
        @session = session
      end
    end
  end
end





# puts database.collection_names
get '/api/v1/hello' do
  json({msg: 'hello world! im working'})
end

post '/api/v1/hello' do
  if !checkParameters(params, ['name'])
    halt 400
  end
  name = params[:name]
  record = {msg: "hello #{name}!"}
  database[:bob].insert_one(record)
  json(record)
end

# Profile endpoints
# post new

profileParams = ['full_name', 'email', 'address', 'phone_number', 'signature', 'camp_id', 'status', 'bio', 'user_name', 'password']
signupParams = ['name', 'email', 'password', 'role']


post '/api/v1/profiles' do
  if !checkParameters(@params, signupParams)
    halt 400, "the requirements were not met, did not post to database"
  else
    sendEmail('spyeadon@gmail.com', 'no-reply@fakedomain.io', 'test of sign-up confirmation', 'plain text test')
  end
  # json database[:profiles].insert_one(params)
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
  if !checkParameters(params, profileParams)
    halt 400, "the requirements were not met, did not post to database"
  end
  json database[:profiles].update_one(
    {'_id' => BSON::ObjectId(idnumber)}, {'$set' => params }
  )
end

delete '/api/v1/profiles/:_id' do

  database[:profiles].delete_one( {_id: BSON::ObjectId(params[:_id]) } )

end

# Camp endpoints
get '/api/v1/applications/camps' do
  data = []
  database[:camps].find.each do |document|
    data << document.to_h
  end
  json data
end

campParams = ['full_name', 'email', 'address', 'phone_number', 'signature', 'camp_id', 'status', 'bio']

post '/api/v1/applications/camps' do
  if !checkParameters(params, campParams)
    halt 400, "the requirements were not met, did not post to database"
  end
  json database[:camps].insert_one(params)
end

get '/api/v1/applications/camps/:_id' do

  json database[:camps].find(:_id => BSON::ObjectId(params[:_id])).first

end

put '/api/v1/applications/camps/:_id' do
  id_number = params.delete("_id")
  if !checkParameters(params, campParams)
    halt 400, "the requirements were not met, did not post to database"
  end

  json database[:camps].update_one( { '_id' => BSON::ObjectId(id_number) },   { '$set' => params})

end

delete '/api/v1/applications/camps/:_id' do

  database[:camps].delete_one( {_id: BSON::ObjectId(params[:_id]) } )

end

# Volunteer endpoints

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
  if !checkParameters(params, profileParams)
    halt 400, "the requirements were not met, did not post to database"
  end
  json database[:volunteers].insert_one(params)
end


put '/api/v1/applications/volunteers/:id' do
  idnumber = params.delete("id")
  if !checkParameters(params, profileParams)
    halt 400, "the requirements were not met, did not post to database"
  end
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

#sessions endpoints

post '/api/v1/sessions/:user_name/:password' do
  data = []
  results = database[:profiles].find(:user_name => (params[:user_name])).first

  if !results
    halt(401)
  elsif results[:password] === (params[:password])
    token = database[:sessions].insert_one(params)
    data << token.inserted_id
    data << results
  else
    halt(401)
  end

 return {"X_TOKEN"=> token.inserted_id.to_s, "profileData" => results}.to_json
end

delete '/api/v1/sessions/:_id' do

  if (params[:_id]) != @token
    halt(401, "Invalid Token")
  else
    database[:sessions].delete_one( {_id: BSON::ObjectId(params[:_id]) } )
    return "deleted"
  end
end

get '/api/v1/sessions/:_id' do
  if (params[:_id]) != @token
    halt(401, "Invalid Token")
  else
    checkedSession = database[:sessions].find(:_id => BSON::ObjectId(params[:_id])).first
    return {"X_TOKEN" => checkedSession[:_id].to_s}.to_json

  end
end

# webpage resources

get '/api/v1/resources/:pagename' do
  result = database[:pageresources].find(:name => params[:pagename])

  if result.count.zero?
    json 0
  else
    json result.first['dataObj']
  end
end

# faq endpoints

get '/api/v1/faq' do
  data = []
  database[:faqs].find.each do |faq|
    data << faq.to_h
  end
  json data
end

newQuestionParams = ['name', 'email', 'message']

post '/api/v1/faq' do
  if !checkParameters(@params, newQuestionParams)
    halt 400, "the requirements were not met, did not post question to WRNG staff"
  else
    message = @params['message'] + " - Question Submitted By: " + @params['name']
    email = @params['email']
    sendEmail(ENV['faq_email'], email, 'FAQ Submission', message)
  end
end


# camp info endpoints

get '/api/v1/campinfo' do
  data = []
  database[:campinfo].find.each do |info|
    data << info.to_h
  end
  json data
end

# profile page endpoints

get '/api/v1/profile/:_id' do
  if (params[:_id]) != @token
    halt(401, "Invalid Token")
  else
    checkedSession = database[:sessions].find(:_id => BSON::ObjectId(params[:_id])).first
    user = database[:profiles].find(:user_name == checkedSession[:user_name]).first
    json user
  end
end

