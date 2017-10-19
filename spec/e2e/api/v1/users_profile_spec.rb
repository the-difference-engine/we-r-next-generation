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
      # ... other fields e.g. address_1, zip, country, email, phone_number etc.
    end

  end

  describe 'POST /api/v1/users/:user_id/profile' do
    before do
      post_json('/api/v1/users/1/profile', {
          full_name: "Jon Doe",
          address_1: " 4 Matadi Street",
          address_2: " Plot 8c Metalbox   road, off Acme road",
          town: "Ogba",
          province: "Ikeja lagos",
          zip: "20303",
          country: "Nigeria",
          email: "user@gmail.com",
          phone_number: "555-555-5555",
          password: "xxxxxx",
          profile_img: "url_image"
      })
    end

    it 'responds successfully' do
      last_response.status.must_equal 200
    end

  end

end
