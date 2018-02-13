we-r-next-generation
=====

## Getting Started

Before you begin, you must have [Ruby](https://www.ruby-lang.org/en/documentation/installation/), [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git), and [Heroku](https://devcenter.heroku.com/articles/heroku-cli) installed.

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

## Testing

* Run all tests:
`rake spec`
* Run end-to-end tests:
`rake spec:e2e`
* Run unit tests:
`rake spec:units`

Note: End-to-end test are in the `spec/e2e/api/v1` directory while unit test are in the `spec/unit` directory.

## Deploying

Production url: https://wrng.herokuapp.com/

Tip: Make sure Heroku is up-to-date (see https://devcenter.heroku.com/articles/heroku-cli for your platform details).

Use the credentials found in WeRNextGeneration Google Drive to login:
`heroku login`

The first time you run Heroku, set git remote:
`heroku git:remote -a wrng`

Deploy your code to Heroku:
`git push heroku qa:master`