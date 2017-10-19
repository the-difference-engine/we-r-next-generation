# spec/e2e/api/v1/hello_spec.rb

# Pull in the e2e helper for all the test functionality we need
require_relative '../../../e2e_helper.rb'

# Notice the spec name ending in `E2E` this is important, it lets minitest know we want this test to be a `E2eTest`
describe 'HelloE2E' do

  describe 'GET /api/v1/hello' do
    before { get '/api/v1/hello' }
    let(:json) { json_parse(last_response.body) }

    it 'responds successfully' do
      # Ensure the request we just made gives us a 200 status code
      last_response.status.must_equal 200
    end

    it 'have a msg property with the text "hello world!"' do
      json[:msg].must_equal 'hello world!'
    end

  end

  describe 'POST /api/v1/hello' do
    before { post_json("/api/v1/hello", {name: 'sam'}) }
    let(:resp) { json_parse(last_response.body) }

    it 'respond with json with msg property of "hello sam!"' do
      resp[:msg].must_equal 'hello sam!'
    end

  end

end
