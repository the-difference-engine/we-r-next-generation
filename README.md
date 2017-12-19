# we-r-next-generation

# Getting Started

1. `clone https://github.com/the-difference-engine/we-r-next-generation.git`
2. `cd we-r-next-generation`
3. `bundle install`
4. `curl -X GET http://localhost:4567/api/v1/hello` which should return `{"msg":"hello world!"}`
5. `curl -H "Content-Type: application/json" -X POST -d '{"name":"john"}' http://localhost:4567/api/v1/hello` which should return `{"msg":"hello john!"}`

# Tests

1. `rake spec`

end to end test are in the `spec/e2e/api/v1` directory while unit test are in the `spec/unit` directory  

# Heroku 
- url: https://wrng.herokuapp.com/

update your heroku if needed
`brew install heroku`

in your command line
`heroku login`
use the credentials found in WeRNextGeneration Google Drive to login

`heroku git:remote -a wrng`
run this command just once, for the first time, this sets git remote


`git push heroku:master`


