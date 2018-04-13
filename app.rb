# app.rb

require 'sinatra'
require 'sinatra/json'
require 'rack'
require 'rack/contrib'
require_relative 'validate'
require_relative 'emailUtils'
require 'mongo'
require 'sinatra/cors'
require 'digest'


use Rack::PostBodyContentTypeParser
# Set MONGODB_URL
database = Mongo::Client.new(ENV["MONGODB_URL"])

set :allow_origin, "*"
set :allow_methods, "GET,HEAD,POST,DELETE,PUT"
set :allow_headers, "content-type,if-modified-since, x-token"
set :expose_headers, "location,link"

postWhitelist = ['sessions', 'faq', 'profiles']
getWhitelist = ['resources', 'faq', 'campinfo', 'opportunities', 'applications/volunteers', 'camp/session', 'camp/sessions']
putWhiteList = ['profiles/activate', 'profiles/resetPassword', 'profiles/newPassword']
before '*' do

  if (postWhitelist.any? { |value| request.path_info.include? '/api/v1/' + value}) && (request.request_method == "POST")
    next

  elsif (getWhitelist.any? { |value| request.path_info.include? '/api/v1/' + value}) && (request.request_method == "GET")
    puts "Get White Listed"
    next

  elsif (putWhiteList.any? { |value| request.path_info.include? '/api/v1/' + value}) && (request.request_method == "PUT")
    next

  elsif request.request_method == "OPTIONS"
    next

  else
    puts "Checking Token"
    collection = database[:sessions]
    @token = request.env['HTTP_X_TOKEN']
    if !@token
      @token = request.env['rack.request.form_hash'] || ''
      @token = @token['headers'] || ''
      @token = @token['x-token'] || ''
    end

    if !@token
      puts 'ha'
      halt(401, "Invalid Token")
    elsif !BSON::ObjectId.legal?(@token)
      puts 'haha'
      halt(401, "Invalid Token")
    else
      session = collection.find( {:_id => BSON::ObjectId(@token) }).first
      if session.nil?
        puts 'hahaha'
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
signupParams = ['name', 'email', 'password']


post '/api/v1/profiles' do
  newProfile = params['params']
  if !checkSignupParameters(newProfile, signupParams)
    halt 400, "the requirements were not met, did not post to database"
  elsif database[:profiles].find(:email => newProfile['email']).first
    halt 400, "a profile with this email address already exists"
  else
    newProfile[:full_name] = newProfile.delete :name
    newProfile['active'] = false
    profInDB = database[:profiles].insert_one(newProfile)
    url = 'http://localhost:8080/#/confirmation/' + profInDB.inserted_id.to_s
    sendEmail(newProfile['email'],
              'no-reply@fakedomain.io',
              'WeRNextGeneration - Sign Up Confirmation',
              'dummy plain text',
              "Follow the link below to activate your account: <br><br> <a href=\"#{url}\">Activate Account</a>"
    )
    json 200
  end
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

# camp experience sessions endpoints

# get all
get '/api/v1/camp/session/get' do
  data=[]
  database[:camp_sessions].find.each do |camp|
    data << camp.to_h
  end
  json(data)
end

# get all, sort by Field Name, default = date_start DESC
get '/api/v1/camp/sessions', :provides => :json do
  data=[]
  puts "HERE IN CAMP SESSIONS SORT"
  # if params[:field_name]
  #   database[:camps].find.order(params[:field_name] + " " + params[:order]).each do |camp|
  #     data << camp.to_h
  #   end
  # else
  database[:camp_sessions].find.each do |camp|
    data << camp.to_h
    # end
  end
  json(data)
end

post '/api/v1/camp/session/create' do
  newCamp = params['params']
  createdCamp = database[:camp_sessions].insert_one(newCamp)
  json createdCamp
end


put '/api/v1/camp/session/:id/update' do
  content_type :json
  updatedCamp = params['params']
  puts "UPDATED CAMP"
  database[:camp_sessions].find(:_id => BSON::ObjectId(params[:id])).
    update_one('$set' => {
      'name' => updatedCamp['name'],
      'date_start' => updatedCamp['date_start'],
      'date_end' => updatedCamp['date_end'],
      'description' => updatedCamp['description'],
      'poc' => updatedCamp['poc'],
      'limit' => updatedCamp['limit'],
      'status' => updatedCamp['status']
    }, '$currentDate' => { 'updated_at' => true })
  updatedCamp = database[:camp_sessions].find(:_id => BSON::ObjectId(params[:id])).first.to_h
  json updatedCamp
end

# get list of applicants related to the camp session id (string)
get '/api/v1/camp/session/:id/applicants', :provides => :json do
  data = []
  if params[:id]
    database[:applications].find(:camp => params[:id]).each do |applicant|
      data << applicant.to_h
    end
    json(data)
  end
end

get '/api/v1/camp/session/:id', :provides => :json do
  if params[:id]
    data = database[:camp_sessions].find(:_id => BSON::ObjectId(params[:id])).first
    json data
  else
    json({msg: 'Error: Camp Not Found'})
  end
end


put '/api/v1/profiles/activate/:_id' do

  if params[:_id] && database[:profiles].find(:_id => BSON::ObjectId(params[:_id])).first
    profile = database[:profiles].find(:_id => BSON::ObjectId(params[:_id])).first
    if !profile['active']
      json database[:profiles].update_one({:_id =>BSON::ObjectId(params[:_id])}, {'$set' => {active: true}})
    else
      halt 200, "profile has already been activated"
    end
  else
    halt 400, "profile ID invalid, could not activate account"
  end

end

put '/api/v1/profiles/resetPassword/:email' do
  email = params[:email]
  profile = database[:profiles].find(:email => email).first
  if !profile || !profile[:active]
    halt 400, "there is no active profile with that email"
  end
  md5 = Digest::MD5.new
  md5.update (email + DateTime.now().to_s)
  database[:profiles].update_one({:email => email}, {'$set' => {resetToken: md5.hexdigest}})
  url = 'http://localhost:8080/#/newPassword/' + md5.hexdigest
  sendEmail(email,
            'no-reply@fakedomain.io',
            'WeRNextGeneration - Password Reset',
            'dummy plain text',
            "Follow the link below to reset your password: <br><br> <a href=\"#{url}\">Reset Password</a>"
  )
  json 200
end

put '/api/v1/profiles/newPassword/:resetToken/:password' do
  profile = database[:profiles].find(:resetToken => params[:resetToken]).first
  if profile && profile[:active]
  database[:profiles].update_one({:resetToken => params[:resetToken]}, {'$set' => {password: params[:password], resetToken: ''}})
  json 200
  else
    halt 400, "no profile found with that reset token"
  end
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

post '/api/v1/applications' do
  app = database[:applications].insert_one(params['params'])
  json app.inserted_ids[0]
end

post '/api/v1/applications/waiver' do
  app = database[:applications].insert_one(params['params']['application'])
  app_id = app.inserted_ids[0].to_s
  waiver = params['params']['waiver']
  waiver['application'] = app_id
  waiver = database[:waivers].insert_one(waiver)
  json app_id
end

get '/api/v1/applications/:id/waiver' do
  if params[:id]
    data = database[:waivers].find(:application => params[:id]).first
    json data
  else
    json({msg: 'Error: Waiver Not Found'})
  end
end

# Camp endpoints !!!!! this is no longer needed, but this code can be used for updating camps maybe?
# get '/api/v1/applications/camps' do
#   data = []
#   database[:camps].find.each do |document|
#     data << document.to_h
#   end
#   json data
# end
#
# campParams = ['full_name', 'email', 'address', 'phone_number', 'signature', 'camp_id', 'status', 'bio']
#
# post '/api/v1/applications/camps' do
#   if !checkParameters(params, campParams)
#     halt 400, "the requirements were not met, did not post to database"
#   end
#   json database[:camps].insert_one(params)
# end
#
# get '/api/v1/applications/camps/:_id' do
#
#   json database[:camps].find(:_id => BSON::ObjectId(params[:_id])).first
#
# end
#
# put '/api/v1/applications/camps/:_id' do
#   id_number = params.delete("_id")
#   if !checkParameters(params, campParams)
#     halt 400, "the requirements were not met, did not post to database"
#   end
#
#   json database[:camps].update_one( { '_id' => BSON::ObjectId(id_number) },   { '$set' => params})
#
# end
#
# delete '/api/v1/applications/camps/:_id' do
#
#   database[:camps].delete_one( {_id: BSON::ObjectId(params[:_id]) } )
#
# end

# Volunteer endpoints

get '/api/v1/applications/:type' do
  type = params[:type]
  applications = {
    submitted: {:icon => 'fa fa-edit', :apps => {}, :next => 'pending'},
    pending: {:icon => 'fa fa-clock-o', :apps => {}, :prev => 'submitted', :reject => 'not_approved', :approve => 'approved'},
    approved: {:icon => 'fa fa-check', :apps => {}, :prev => 'pending'},
    not_approved: {:icon => 'fa fa-times', :apps => {}, :prev => 'pending', :next => 'delete'}
  }
  allApplications = []

  database[:applications].find.each do |application|
    if type === 'all'
      allApplications << application.to_h
    elsif application[:type] == type
      status = application[:status].to_sym
      id = application[:_id].to_s
      applications[status][:apps][id] = application.to_h
    end
  end

  if type === 'all'
    return {"applications" => allApplications, "type" => type}.to_json
  else
    return {"applications" => applications, "type" => type}.to_json
  end
end

put '/api/v1/applications/status/:id' do
  id = params[:id]
  newParams = params['params']
  application = database[:applications].find({'_id' => BSON::ObjectId(id)}).first

  if application
    database[:applications].update_one({'_id' => BSON::ObjectId(id)}, {'$set' => {status: newParams['statusChange']}})
    json database[:applications].find({'_id' => BSON::ObjectId(id)}).first
  else
    halt 400, "could not find this application in the database"
  end

end

delete '/api/v1/applications/:id' do
  if database[:applications].find({:_id => BSON::ObjectId(params[:id])}).first
    database[:applications].delete_one( {_id: BSON::ObjectId(params[:id]) } )
    halt 200, "record deleted"
  else
    halt 400, "could not find this application in the database"
  end
end

# get '/api/v1/applications/volunteers/:_id' do
#   json database[:volunteers].find(:_id => BSON::ObjectId(params[:_id])).first
# end


# post '/api/v1/applications/volunteers' do
#   if !checkParameters(params, profileParams)
#     halt 400, "the requirements were not met, did not post to database"
#   end
#   json database[:volunteers].insert_one(params)
# end
#

# camp experience sessions endpoints

# get '/api/v1/camp/session/all' do
#   data = []
#   database[:camps].find.each do |document|
#     data << document.to_h
#   end
#   json data
# end

#sessions endpoints

post '/api/v1/sessions/:email/:password' do
  data = []
  results = database[:profiles].find(:email => (params[:email])).first

  if !results
    halt(401)
  elsif (results[:password] === (params[:password]) && results[:active] === true)
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
    profileData = database[:profiles].find(:email => checkedSession[:email]).first
    return {"X_TOKEN" => checkedSession[:_id].to_s, "profileData" => profileData}.to_json

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
    user = database[:profiles].find(:email => checkedSession[:email]).first
    json user
  end
end

# opportunities endpoints

get '/api/v1/opportunities' do
  data = []
  database[:opportunities].find.each do |info|
    data << info.to_h
  end
  json data
end

