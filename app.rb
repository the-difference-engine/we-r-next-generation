# app.rb

require 'sinatra'
require 'sinatra/json'
require 'rack'
require 'rack/contrib'
require_relative 'validate'
require_relative 'emailUtils'
require_relative 'pswdSecurity'
require 'mongo'
require 'sinatra/cors'
require 'pry'

use Rack::PostBodyContentTypeParser
# Set MONGODB_URL
database = Mongo::Client.new(ENV["MONGODB_URL"])

set :allow_origin, "*"
set :allow_methods, "GET,HEAD,POST,DELETE,PUT"
set :allow_headers, "content-type,if-modified-since, x-token"
set :expose_headers, "location,link"

postWhitelist = ['sessions', 'faq', 'profiles']
getWhitelist = ['resources', 'faq', 'campinfo', 'opportunities', 'applications/volunteers', 'successStories', 'hello']
putWhiteList = ['profiles/activate', 'profiles/resetPassword', 'profiles/newPassword']

before '*' do
  puts "beginning of before do"
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
      if !@token
        halt(401, "No token received from browser request")
      end
    end

    if @token
      puts "Token exists, now to make sure it's valid"
      session = collection.find( {:_id => BSON::ObjectId(@token) }).first
      @profile = database[:profiles].find(:email => session[:email]).first
      if session.nil?
        puts "Session object from token is nil"
        halt(401, "Invalid Token")
      elsif !BSON::ObjectId.legal?(@token)
        puts "Invalid Format For Token"
        halt(401, "Invalid Token")
      elsif request.path_info.include? '/admin/'
        puts "Checking admin credentials"
        if !@profile || @profile[:role] != 'admin'
          halt(401, "Admin profile required")
        end
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
signupParams = ['name', 'email', 'password', 'password_hash']

post '/api/v1/profiles' do
  newProfile = params
  newProfile['password_hash'] = createPasswordHash(params['password'])
  if !checkSignupParameters(newProfile, signupParams)
    halt 400, "the requirements were not met, did not post to database"
  elsif database[:profiles].find(:email => newProfile['email']).first
    halt 400, "a profile with this email address already exists"
  else
    newProfile[:full_name] = newProfile.delete :name
    newProfile['active'] = true
    newProfile.delete('password')
    profInDB = database[:profiles].insert_one(newProfile)
    url = 'http://localhost:8080/#/confirmation/' + profInDB.inserted_id.to_s
    begin
      sendEmail(
        newProfile['email'],
        'no-reply@fakedomain.io',
        'WeRNextGeneration - Sign Up Confirmation',
        "Navigate to this link to activate your account: #{url}",
        "Follow the link below to activate your account: <br><br> <a href=\"#{url}\">Activate Account</a>"
      )
    rescue Exception => e
      puts "ERROR: #{e.message}"
      puts "Error sending email to confirm sign-up for user #{newProfile['email']}"
    end
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

put '/api/v1/profiles/resetPassword' do
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

put '/api/v1/profiles/newPassword' do
  profile = database[:profiles].find(:resetToken => params[:resetToken]).first
  if profile && profile[:active]
    password_hash = createPasswordHash(params[:password])
    database[:profiles].update_one({:resetToken => params[:resetToken]}, {'$set' => {password_hash: password_hash, resetToken: ''}})
    json 200
  else
    halt 400, "no profile found with that reset token"
  end
end

put '/api/v1/profiles/:id' do
  idnumber = params.delete("id")

  if !@profile || @profile[:role] != 'superadmin'
    if !checkParameters(params, profileParams)
      halt 400, "the requirements were not met, did not post to database"
    end
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

# Volunteer endpoints

get '/api/v1/admin/applications/:type' do
  type = params[:type]
  applications = {
    submitted: {:icon => 'fa fa-edit', :apps => {}, :next => 'pending'},
    pending: {:icon => 'fa fa-clock-o', :apps => {}, :prev => 'submitted', :reject => 'not_approved', :approve => 'approved'},
    approved: {:icon => 'fa fa-check', :apps => {}, :prev => 'pending'},
    not_approved: {:icon => 'fa fa-times', :apps => {}, :prev => 'pending', :next => 'delete'}
  }
  sessions = {}
  if type === 'camper'
    database[:camp_sessions].find.each do |session|
      sessions[session[:_id].to_s] = session.to_h
    end
  end

  database[:applications].find.each do |application|
    if type === 'all'
      status = application[:status].to_sym
      id = application[:_id].to_s
      applications[status][:apps][id] = application.to_h
    elsif application[:type] == type
      status = application[:status].to_sym
      id = application[:_id].to_s
      applications[status][:apps][id] = application.to_h
      if application[:type] === 'camper'
        applications[status][:apps][id]['camp_data'] = sessions[application[:camp]]
      end
    end
  end

    return {"applications" => applications, "type" => type}.to_json
end

get '/api/v1/admin/applications/app/:id' do
  application = database[:applications].find({'_id' => BSON::ObjectId(params[:id])}).first
  if application && (application[:type] === 'camper' || application[:type] === 'volunteer')
    application[:camp_data] = database[:camp_sessions].find({'_id' => BSON::ObjectId(application[:camp])}).first
  end
   json application
end

put '/api/v1/admin/applications/status/:id' do
  id = params[:id]
  newParams = params['params']
  application = database[:applications].find({'_id' => BSON::ObjectId(id)}).first

  if application
    database[:applications].update_one({'_id' => BSON::ObjectId(id)}, {'$set' => {status: newParams['statusChange']}})
    newApplication = database[:applications].find({'_id' => BSON::ObjectId(id)}).first
    if application[:camp]
      newApplication['camp_data'] = database[:camp_sessions].find({'_id' => BSON::ObjectId(application[:camp])}).first
    end
    json newApplication
  else
    halt 400, "could not find this application in the database"
  end
end

delete '/api/v1/admin/applications/:id' do
  if database[:applications].find({:_id => BSON::ObjectId(params[:id])}).first
    database[:applications].delete_one( {_id: BSON::ObjectId(params[:id]) } )
    halt 200, "record deleted"
  else
    halt 400, "could not find this application in the database"
  end
end

#sessions endpoints

post '/api/v1/sessions' do
  data = []
  results = database[:profiles].find({ '$text' => { '$search' => "\"#{params[:email]}\"", '$caseSensitive' => false } } ).first

  if !results
    halt(401)
  elsif (checkPassword(results[:password_hash], params[:password]) && results[:active] === true)
    params.delete('password')
    token = database[:sessions].insert_one(params)
    data << token.inserted_id
    data << results
    results.delete('password_hash')
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

put '/api/v1/resources/update/heroimage' do
  homePage = database[:pageresources].find({:name => 'homepage'}).first['dataObj']
  heroHistory = homePage['heroHistory']
  heroHistory.pop
  heroHistory.unshift(params['heroImage'])
  json database[:pageresources].update_one({'name' => 'homepage'}, {'$set' => {'dataObj.heroImage' => params['heroImage'], 'dataObj.heroHistory' => heroHistory}})
end

post '/api/v1/admin/partner/add' do
  homePage = database[:pageresources].find({:name => 'homepage'}).first['dataObj']
  partners = homePage['partners']
  partners.push(params['partner'])
  json database[:pageresources].update_one({'name' => 'homepage'}, '$set' => {'dataObj.partners' => partners})
end

post '/api/v1/admin/partner/delete' do
  homePage = database[:pageresources].find({:name => 'homepage'}).first['dataObj']
  partners = homePage['partners']
  partners.delete_at(params['index'].to_i)
  json database[:pageresources].update_one({'name' => 'homepage'}, '$set' => {'dataObj.partners' => partners})
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

# Success Stories

get '/api/v1/successStories' do
  data = []
  database[:success_stories].find.each do |info|
    data << info.to_h
  end
  json data
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

# administrative edit endpoints

put '/api/v1/admin/waiver/:type/update' do
  content_type :json
  waiver_type = "waiver_" + params[:type]
  updated_waiver = params['data']
  waiver = database[:pageresources].update_one({:name => waiver_type},
    {'$set' => {
      'dataObj' => updated_waiver
    }, '$currentDate' => { 'updated_at' => true }})
  json waiver
end

# faq edits

get '/api/v1/faqEdit/:_id' do
  json database[:faqs].find(:_id => BSON::ObjectId(params[:_id])).first
end

post '/api/v1/faqEdit/:id' do
  content_type :json
  updatedFaq = params['params']
  database[:faqs].find(:_id => BSON::ObjectId(params[:id])).
    update_one('$set' => {
      'question' => updatedFaq['question'],
      'answer' => updatedFaq['answer'],
      'category' => updatedFaq['category'],
    },)
  updatedFaq = database[:faqs].find(:_id => BSON::ObjectId(params[:id])).first.to_h
  json updatedFaq
end

delete '/api/v1/faqEdit/:id' do
  if database[:faqs].find({:_id => BSON::ObjectId(params[:id])}).first
    database[:faqs].delete_one( {_id: BSON::ObjectId(params[:id]) } )
    halt 200, "faq deleted"
  else
    halt 400, "could not find this faq in the database"
  end
end

post '/api/v1/faqAdd' do
  newFaq = database[:faqs].insert_one(params['params'])
  json newFaq.inserted_ids[0]
end

# success Edits

get '/api/v1/successEdit/:_id' do
  json database[:success_stories].find(:_id => BSON::ObjectId(params[:_id])).first
end

post '/api/v1/successEdit/:id' do
  content_type :json
  updatedStory = params['params']
  database[:success_stories].find(:_id => BSON::ObjectId(params[:id])).
    update_one('$set' => {
      'about' => updatedStory['about'],
      'learned' => updatedStory['learned'],
      'image' => updatedStory['image'],
    },)
  updatedStory = database[:success_stories].find(:_id => BSON::ObjectId(params[:id])).first.to_h
  json updatedStory
end

post '/api/v1/successAdd' do
  newStory = database[:success_stories].insert_one(params['params'])
  json newStory.inserted_ids[0]
end

delete '/api/v1/successEdit/:id' do
  if database[:success_stories].find({:_id => BSON::ObjectId(params[:id])}).first
    database[:success_stories].delete_one( {_id: BSON::ObjectId(params[:id]) } )
    halt 200, "success story deleted"
  else
    halt 400, "could not find this success story in the database"
  end
end
