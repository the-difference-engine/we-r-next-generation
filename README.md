# we-r-next-generation

# Getting Started

1. Download code repository:
`git clone git@github.com:the-difference-engine/we-r-next-generation.git`
2. Navigate to project directory:
`cd we-r-next-generation`
3. Install dependencies:
`bundle install`
4. Confirm application handles requests:
	* GET request:
	`curl -X GET http://localhost:4567/api/v1/hello` which should return `{"msg":"hello world!"}`
	* POST request:
	`curl -H "Content-Type: application/json" -X POST -d '{"name":"john"}' http://localhost:4567/api/v1/hello` which should return `{"msg":"hello john!"}`

# Tests

* Run all tests:
`rake spec`
* Run end-to-end tests:
`rake spec:e2e`
* Run unit tests:
`rake spec:units`

Note: End-to-end test are in the `spec/e2e/api/v1` directory while unit test are in the `spec/unit` directory.

# Heroku 
- url: https://wrng.herokuapp.com/

Update your heroku if needed

`brew install heroku`

`heroku login`

Use the credentials found in WeRNextGeneration Google Drive to login

`heroku git:remote -a wrng`

Run this command just once, for the first time, this sets git remote


`git push heroku qa:master`

This deploys your code into Heroku