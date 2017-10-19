# config.ru

require 'rack'
require 'rack/contrib'

require File.join(File.dirname(__FILE__), 'app')

use Rack::PostBodyContentTypeParser

run Sinatra::Application
