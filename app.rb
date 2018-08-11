# frozen_string_literal: true

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
DATABASE = Mongo::Client.new(ENV['MONGODB_URL'])
Mongoid.load! 'mongoid.yml'

class WeRNextGenerationApp < Sinatra::Base
  register Sinatra::Cors

  set :allow_origin, '*'
  set :allow_methods, 'GET,HEAD,POST,DELETE,PUT,OPTIONS'
  set :allow_headers, 'content-type,if-modified-since,x-token'
  set :expose_headers, 'location,link'

  post_white_list = [
    'sessions',
    'faq',
    'profiles',
    'applications/waiver/:id',
    'camp/session/create'
  ]
  get_white_list = [
    'resources',
    'faq',
    'campinfo',
    'opportunities',
    'applications/volunteers',
    'successStories',
    'health-check',
    'resetPassword'
  ]
  put_white_list = [
    'profiles/activate',
    'updatePassword'
  ]

  before '*' do
    if (post_white_list.any? { |value| request.path_info.include? '/api/v1/' + value }) && \
       (request.request_method == 'POST')
      next

    elsif (get_white_list.any? { |value| request.path_info.include? '/api/v1/' + value }) && \
          (request.request_method == 'GET')
      next

    elsif (put_white_list.any? { |value| request.path_info.include? '/api/v1/' + value }) && \
          (request.request_method == 'PUT')
      next

    elsif request.request_method == 'OPTIONS'
      next

    else
      @token = request.env['HTTP_X_TOKEN']
      unless @token
        @token = request.env['rack.request.form_hash'] || ''
        @token = @token['headers'] || ''
        @token = @token['x-token'] || ''
      end

      halt(401, 'No token received from browser request') if @token.nil? || @token.empty?

      @session = Session.find(id: @token)
      @profile = Profile.find_by(email: @session[:email])
      halt(401, 'Invalid Token') if @session.nil?
      halt(401, 'Invalid Token') unless BSON::ObjectId.legal?(@token)

      halt(401, 'Minimum admin profile required') if (request.path_info.include? '/admin/') && \
                                                     (!@profile || !%w[admin superadmin].include?(@profile.role))
    end
  end

  options '*' do
    200
  end

  get '/api/v1/health-check' do
    Application.first
    CampInfo.first
    CampSession.first
    FAQ.first
    Opportunity.first
    PageResource.first
    Profile.first
    Session.first
    SuccessStory.first
    Waiver.first
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
  run!
end
