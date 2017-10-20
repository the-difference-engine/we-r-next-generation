# spec/e2e/api/v1/users_profile_spec.rb

# todo: impediment
# Pull in the e2e helper for all the test functionality we need
require_relative '../../../e2e_helper.rb'

# Notice the spec name ending in `E2E` this is important, it lets minitest know we want this test to be a `E2eTest`
describe 'UsersProfileE2E' do


  describe 'GET /api/v1/applications/volunteers' do
    before { get '/api/v1/applications/volunteers' }
    let(:json) { json_parse(last_response.body) }

      it 'have a full_name property with the value of "Victor Lee"' do
        json[:volunteers][0][:full_name].must_equal 'Victor Lee'
        # ... other fields e.g. address_1, zip, country, email, phone_number etc.
      end
  end

  describe 'POST' do
    before do
      post_json('/api/v1/applications/volunteers', 
        {
          full_name: "Natale Anfuso",
          email: "nanfuso@gmail.com",
          address: "3 Clark St",
          phone_number: "312-995-5832",
          bio: "Hi",
          signature: "NA",
          camp_id: "2",
          status: "Active",
          user_id: 2
        }
        )
    end

    it 'responds successfully' do
      last_response.status.must_equal 200
    end
  end






end