# We-R-Next-Generation

## What this is
This is part of the We-R-Next-Generation web application. It is written in Ruby using the Sinatra library and deployed to Heroku. This API provides the backend for a single-page application written in JavaScript with the Vue framework.

## Standing up a local version of the application for development
- Install [docker][1] and start it locally.
- Clone this repository and the [we-r-next-generation-web repo][2].
- Navigate to this directory at the command line and run `docker-compose up`. This will pull images for MongoDB, Ruby, and Node, build the backend and frontend apps, and stand up three containers.
- Once you have this running, the frontend will be accessible on localhost:8080 and the backend will be accessible on localhost:4567.

[1]: https://www.docker.com/community-edition
[2]: https://github.com/the-difference-engine/we-r-next-generation-web

## Deploying the application
- This application is deployed to [Heroku][3]. The existing Heroku account is set up to automatically deploy the application on a merge to the `master` branch. These instructions are only intended to be use if something goes wrong with the automated process in Heroku.
- Install the [Heroku CLI][4]. On the Mac, you can also use homebrew to install the CLI: `brew install heroku`.
- At the command line, run `heroku login` and use the Heroku credentials in the .env file that was provided by TDE. Make sure to update those credentials if you change them in the web interface.
- On your first deploy, you will need to run `heroku git:remote -a wrng`
- To deploy the application from a specific branch, run `git push heroku <branch_name>:master`.

[3]: https://dashboard.heroku.com/
[4]: https://devcenter.heroku.com/articles/heroku-cli
