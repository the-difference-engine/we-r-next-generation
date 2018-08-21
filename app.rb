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

Mongoid.load! 'mongoid.yml'

# Main application class
class WeRNextGenerationApp < Sinatra::Base
  register Sinatra::Cors

  set :allow_origin, '*'
  set :allow_methods, 'GET,HEAD,POST,DELETE,PUT,OPTIONS'
  set :allow_headers, 'content-type,if-modified-since,x-token'
  set :expose_headers, 'location,link'

  use Rack::PostBodyContentTypeParser

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
    path = request.path_info
    req_method = request.request_method
    next if (post_white_list.any? { |value| path.include? '/api/v1/' + value }) && (req_method == 'POST')
    next if (get_white_list.any? { |value| path.include? '/api/v1/' + value }) && (req_method == 'GET')
    next if (put_white_list.any? { |value| path.include? '/api/v1/' + value }) && (req_method == 'PUT')
    next if req_method == 'OPTIONS'
    validate_token(request)
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
  register Sinatra::WeRNextGenerationApp::Routing::CampInformation
  register Sinatra::WeRNextGenerationApp::Routing::CampSessions
  register Sinatra::WeRNextGenerationApp::Routing::FAQs
  register Sinatra::WeRNextGenerationApp::Routing::Opportunities
  register Sinatra::WeRNextGenerationApp::Routing::PageResources
  register Sinatra::WeRNextGenerationApp::Routing::Profiles
  register Sinatra::WeRNextGenerationApp::Routing::Sessions
  register Sinatra::WeRNextGenerationApp::Routing::SuccessStories
  run!
end
