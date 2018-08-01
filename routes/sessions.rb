module Sinatra
  module WeRNextGenerationApp
    module Routing
      module Sessions

        def self.registered(app)

          create_session = lambda do
            data = []
            results = DATABASE[:profiles].find({ '$text' => { '$search' => "\"#{params[:email]}\"", '$caseSensitive' => false } } ).first

            if !results
              halt(401)
            elsif (checkPassword(results[:password_hash], params[:password]) && results[:active] === true)
              params.delete('password')
              token = DATABASE[:sessions].insert_one(params)
              data << token.inserted_id
              data << results
              results.delete('password_hash')
            else
              halt(401)
            end

            return {"X_TOKEN"=> token.inserted_id.to_s, "profileData" => results}.to_json
          end

          delete_session = lambda do

            if (params[:_id]) != @token
              halt(401, "Invalid Token")
            else
              DATABASE[:sessions].delete_one( {_id: BSON::ObjectId(params[:_id]) } )
              return "deleted"
            end
          end

          get_session = lambda do
            if (params[:_id]) != @token
              halt(401, "Invalid Token")
            else
              checkedSession = DATABASE[:sessions].find(:_id => BSON::ObjectId(params[:_id])).first
              profileData = DATABASE[:profiles].find(:email => checkedSession[:email]).first
              return {"X_TOKEN" => checkedSession[:_id].to_s, "profileData" => profileData}.to_json

            end
          end

          app.post '/api/v1/sessions', &create_session
          app.delete '/api/v1/sessions/:_id', &delete_session
          app.get '/api/v1/sessions/:_id', &get_session

        end

      end
    end
  end
end