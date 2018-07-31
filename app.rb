# app.rb

require 'sinatra/base'
require 'sinatra/json'
require 'rack'
require 'rack/contrib'
require 'mongo'
require 'sinatra/cors'
require 'pry'

require_relative 'validate'
require_relative 'emailUtils'
require_relative 'pswdSecurity'

require_relative 'routes/profiles'
require_relative 'routes/camp_sessions'
require_relative 'routes/applications'
require_relative 'routes/sessions'
require_relative 'routes/page_resources'
require_relative 'routes/partners'
require_relative 'routes/faqs'
require_relative 'routes/success_stories'
require_relative 'routes/camp_info'
require_relative 'routes/opportunities'
require_relative 'routes/waivers'

# Set MONGODB_URL
DATABASE = Mongo::Client.new(ENV["MONGODB_URL"])

class WeRNextGenerationApp < Sinatra::Base

  set :allow_origin, "*"
  set :allow_methods, "GET,HEAD,POST,DELETE,PUT"
  set :allow_headers, "content-type,if-modified-since,x-token"
  set :expose_headers, "location,link"

  postWhitelist = ['sessions', 'faq', 'profiles', 'applications/waiver/:id', 'camp/session/create']
  getWhitelist = ['resources', 'faq', 'campinfo', 'opportunities', 'applications/volunteers', 'successStories', 'hello']
  putWhiteList = ['profiles/activate', 'profiles/resetPassword', 'profiles/newPassword']

  before '*' do 
    if (postWhitelist.any? { |value| request.path_info.include? '/api/v1/' + value}) && (request.request_method == "POST")
      next

    elsif (getWhitelist.any? { |value| request.path_info.include? '/api/v1/' + value}) && (request.request_method == "GET")
      next

    elsif (putWhiteList.any? { |value| request.path_info.include? '/api/v1/' + value}) && (request.request_method == "PUT")
      next

    elsif request.request_method == "OPTIONS"
      next

    else
      collection = DATABASE[:sessions]
      @token = request.env['HTTP_X_TOKEN']
      if !@token
        @token = request.env['rack.request.form_hash'] || ''
        @token = @token['headers'] || ''
        @token = @token['x-token'] || ''
      end
   
      if (@token.nil? || @token.empty?)
        halt(401, "No token received from browser request")
      else
        session = collection.find( {:_id => BSON::ObjectId(@token) }).first
        @profile = DATABASE[:profiles].find(:email => session[:email]).first
        if session.nil?
          halt(401, "Invalid Token")
        elsif !BSON::ObjectId.legal?(@token)
          halt(401, "Invalid Token")
        elsif request.path_info.include? '/admin/'
          if !@profile || !['admin', 'superadmin'].include?(@profile[:role])
            halt(401, "Minimum admin profile required")
          end
        end
      end
    end
  end

  # Health check
  get '/api/v1/hello' do
    json({msg: 'hello world! im working.'})
  end

  register Sinatra::WeRNextGenerationApp::Routing::Profiles
  register Sinatra::WeRNextGenerationApp::Routing::CampSessions
  register Sinatra::WeRNextGenerationApp::Routing::Applications
  register Sinatra::WeRNextGenerationApp::Routing::Sessions
  register Sinatra::WeRNextGenerationApp::Routing::PageResources
  register Sinatra::WeRNextGenerationApp::Routing::Partners
  register Sinatra::WeRNextGenerationApp::Routing::FAQs
  register Sinatra::WeRNextGenerationApp::Routing::SuccessStories
  register Sinatra::WeRNextGenerationApp::Routing::CampInfo
  register Sinatra::WeRNextGenerationApp::Routing::Opportunities
  register Sinatra::WeRNextGenerationApp::Routing::Waivers
end