module Sinatra
  module WeRNextGenerationApp
    module Routing
      module Sessions

        def self.registered(app)

          create_session = lambda do
            profile = Profile.find_by(email: params[:email])
            if !profile
              halt 404
            else
              if checkPassword(profile.password_hash, params[:password]) && profile.active === true
                session = Session.create(email: profile.email)
                json(X_TOKEN: session.id.to_s, profileData: profile)
              else
                halt 401
              end
            end
          end

          get_session = lambda do
            if (params[:id]) != @token
              halt(401, "Invalid Token")
            else
              session = Session.find(params[:id])
              profile = Profile.find_by(email: session.email)
              json(X_TOKEN: session.id.to_s, profileData: profile)
            end
          end

          delete_session = lambda do
            if (params[:id]) != @token
              halt 401, "Invalid Token"
            else
              Session.find(params[:id]).destroy
              200
            end
          end

          app.post '/api/v1/sessions', &create_session
          app.get '/api/v1/sessions/:id', &get_session
          app.delete '/api/v1/sessions/:id', &delete_session

        end

      end
    end
  end
end