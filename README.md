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
- url: https://wernextgeneration-api.herokuapp.com/
- https://wernextgeneration.herokuapp.com/

