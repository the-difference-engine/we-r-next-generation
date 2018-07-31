module Sinatra
  module WeRNextGenerationApp
    module Routing
      module Sessions

        def self.registered(app)

          #sessions endpoints

          app.post '/api/v1/sessions' do
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

          app.delete '/api/v1/sessions/:_id' do

            if (params[:_id]) != @token
              halt(401, "Invalid Token")
            else
              DATABASE[:sessions].delete_one( {_id: BSON::ObjectId(params[:_id]) } )
              return "deleted"
            end
          end

          app.get '/api/v1/sessions/:_id' do
            if (params[:_id]) != @token
              halt(401, "Invalid Token")
            else
              checkedSession = DATABASE[:sessions].find(:_id => BSON::ObjectId(params[:_id])).first
              profileData = DATABASE[:profiles].find(:email => checkedSession[:email]).first
              return {"X_TOKEN" => checkedSession[:_id].to_s, "profileData" => profileData}.to_json

            end
          end

        end

      end
    end
  end
end