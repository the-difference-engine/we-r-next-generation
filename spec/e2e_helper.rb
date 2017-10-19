# spec/e2e_helper.rb

require_relative "spec_helper"
require_relative "support/e2e_helpers.rb"

require 'rack/test'

class E2eTest < UnitTest
  include Rack::Test::Methods
  include E2eHelpers

  register_spec_type(/E2E$/, self)

  def app
    Sinatra::Application
  end
end
