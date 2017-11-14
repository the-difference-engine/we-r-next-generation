# spec/e2e/api/v1/users_profile_spec.rb

# Pull in the e2e helper for all the test functionality we need
require_relative '../../../e2e_helper.rb'

# Notice the spec name ending in `E2E` this is important, it lets minitest know we want this test to be a `E2eTest`
describe 'UsersProfileE2E' do

  describe 'GET /api/v1/users/:user_id/profile' do
    before { get '/api/v1/users/1/profile' }
    let(:json) { json_parse(last_response.body) }

    it 'have a full_name property with the value of "Jon Doe"' do
      json[:full_name].must_equal 'Jon Doe'
      json[:address_1].must_equal ' 4 Matadi Street'
    end

  end

  describe 'POST /api/v1/users/:user_id/profile' do
    before do
      post_json('/api/v1/users/3/profile', {:full_name => "Sam Doe"})
    end

    it 'responds successfully' do
      get_json('/api/v1/users/3/profile')[:full_name].must_equal "Sam Doe"
    end

  end

end
