# frozen_string_literal: true

require 'rack'
require 'rack/contrib'

require File.join(File.dirname(__FILE__), 'app')

use Rack::PostBodyContentTypeParser

run WeRNextGenerationApp
