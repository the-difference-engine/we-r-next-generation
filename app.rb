# app.rb

require 'sinatra/base'
require 'sinatra/json'
require 'rack'
require 'rack/contrib'
require 'mongo'
require 'mongoid'
require 'sinatra/cors'
require 'pry'
require 'digest'

require_relative 'helpers'

Dir.glob('routes/*.rb') { |file| require_relative file }
Dir.glob('models/*.rb') { |file| require_relative file }

# Set MONGODB_URL
DATABASE = Mongo::Client.new(ENV["MONGODB_URL"])
Mongoid.load! "mongoid.yml"

class WeRNextGenerationApp < Sinatra::Base

  set :allow_origin, "*"
  set :allow_methods, "GET,HEAD,POST,DELETE,PUT,OPTIONS"
  set :allow_headers, "content-type,if-modified-since,x-token"
  set :expose_headers, "location,link"

  postWhitelist = ['sessions', 'faq', 'profiles', 'applications/waiver/:id', 'camp/session/create']
  getWhitelist = ['resources', 'faq', 'campinfo', 'opportunities', 'applications/volunteers', 'successStories', 'health-check', 'resetPassword']
  putWhiteList = ['profiles/activate', 'updatePassword']

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
      @token = request.env['HTTP_X_TOKEN']
      if !@token
        @token = request.env['rack.request.form_hash'] || ''
        @token = @token['headers'] || ''
        @token = @token['x-token'] || ''
      end
   
      if (@token.nil? || @token.empty?)
        halt(401, "No token received from browser request")
      else
        @session = Session.find(id: @token)
        @profile = Profile.find_by(email: @session[:email])
        if @session.nil?
          halt(401, "Invalid Token")
        elsif !BSON::ObjectId.legal?(@token)
          halt(401, "Invalid Token")
        elsif request.path_info.include? '/admin/'
          if !@profile || !['admin', 'superadmin'].include?(@profile.role)
            halt(401, "Minimum admin profile required")
          end
        end
      end
    end
  end

  options "*" do
    200
  end

  get '/api/v1/health-check' do
    Profile.first()
    Session.first()
    200
  end

  helpers Sinatra::WeRNextGenerationApp::Helpers

  register Sinatra::WeRNextGenerationApp::Routing::Applications
  register Sinatra::WeRNextGenerationApp::Routing::CampInfo
  register Sinatra::WeRNextGenerationApp::Routing::CampSessions
  register Sinatra::WeRNextGenerationApp::Routing::FAQs
  register Sinatra::WeRNextGenerationApp::Routing::Opportunities
  register Sinatra::WeRNextGenerationApp::Routing::PageResources
  register Sinatra::WeRNextGenerationApp::Routing::Profiles
  register Sinatra::WeRNextGenerationApp::Routing::Sessions
  register Sinatra::WeRNextGenerationApp::Routing::SuccessStories
end