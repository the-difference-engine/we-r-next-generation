# frozen_string_literal: true
source 'https://rubygems.org'
ruby '2.4.4'

git_source(:github) {|repo_name| 'https://github.com/#{repo_name}' }

gem 'rack'
gem 'rake'
gem 'rack-contrib'
gem 'sinatra', require: "sinatra/base"
gem 'sinatra-contrib'
gem 'multi_json'
gem 'mongo'
gem 'bson'
gem 'sinatra-cors'
gem 'aws-sdk'
gem 'bcrypt'
gem 'pry'
gem 'thin'

# for tests
group :test do
  gem 'rack-test'
  gem 'mocha'
  gem 'minitest'
  gem 'minitest-rg'
  gem "codeclimate-test-reporter"
end
