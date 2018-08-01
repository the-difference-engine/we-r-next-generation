module Sinatra
  module WeRNextGenerationApp
    module Routing
      module Profiles

        def self.registered(app)

          profileParams = ['full_name', 'email', 'address', 'phone_number', 'signature', 'camp_id', 'status', 'bio', 'user_name', 'password']
          signupParams = ['name', 'email', 'password', 'password_hash']

          get_all_profiles = lambda do
            data=[]
            DATABASE[:profiles].find.each do |profile|
              data << profile.to_h
            end
            json(data)
          end

          create_a_profile = lambda do
            newProfile = params
            newProfile['password_hash'] = createPasswordHash(params['password'])
            if !checkSignupParameters(newProfile, signupParams)
              halt 400, "the requirements were not met, did not post to database"
            elsif DATABASE[:profiles].find(:email => newProfile['email']).first
              halt 400, "a profile with this email address already exists"
            else
              newProfile[:full_name] = newProfile.delete :name
              newProfile['active'] = true
              newProfile.delete('password')
              profInDB = DATABASE[:profiles].insert_one(newProfile)
              url = 'http://localhost:8080/#/confirmation/' + profInDB.inserted_id.to_s
              sendEmail(
                newProfile['email'],
                'no-reply@wernextgeneration.org',
                'WeRNextGeneration - Sign Up Confirmation',
                "Navigate to this link to activate your account: #{url}",
                "Follow the link below to activate your account: <br><br> <a href=\"#{url}\">Activate Account</a>"
              )
              200
            end
          end

          get_profile_by_id = lambda do
            profile_id = params[:profile_id]
            obj_id = BSON::ObjectId(profile_id)
            profile_table = DATABASE[:profiles]
            query_results = profile_table.find(:_id => obj_id)
            match = query_results.first
            json(match.to_h)
          end

          get_profile_by_session_token = lambda do
            if (params[:_id]) != @token
              halt(401, "Invalid Token")
            else
              checkedSession = DATABASE[:sessions].find(:_id => BSON::ObjectId(params[:_id])).first
              user = DATABASE[:profiles].find(:email => checkedSession[:email]).first
              json user
            end
          end

          update_profile_role = lambda do
            idnumber = params.delete("id")

            if !@profile || @profile[:role] != 'superadmin'
              if !checkParameters(params, profileParams)
                halt 400, "the requirements were not met, did not post to database"
              end
            end

            json DATABASE[:profiles].update_one(
              {'_id' => BSON::ObjectId(idnumber)}, {'$set' => {role: params[:role]} }
            )
          end

          update_profile = lambda do
            content_type :json
            formData = params['params']
            DATABASE[:profiles].find(:_id => BSON::ObjectId(params[:id])).
              update_one('$set' => {
                'full_name' => formData['full_name'],
                'email' => formData['email'],
                'password' => formData['password'],
              },)
            updatedInfo = DATABASE[:profiles].find(:_id => BSON::ObjectId(params[:id])).first.to_h
            json updatedInfo
          end

          delete_profile = lambda do
            DATABASE[:profiles].delete_one( {_id: BSON::ObjectId(params[:_id]) } )
          end

          activate_profile = lambda do
            if params[:_id] && DATABASE[:profiles].find(:_id => BSON::ObjectId(params[:_id])).first
              profile = DATABASE[:profiles].find(:_id => BSON::ObjectId(params[:_id])).first
              if !profile['active']
                json DATABASE[:profiles].update_one({:_id =>BSON::ObjectId(params[:_id])}, {'$set' => {active: true}})
              else
                halt 200, "profile has already been activated"
              end
            else
              halt 400, "profile ID invalid, could not activate account"
            end
          end

          reset_profile_password = lambda do
            email = params[:email]
            profile = DATABASE[:profiles].find(:email => email).first
            if !profile || !profile[:active]
              halt 400, "there is no active profile with that email"
            end
            md5 = Digest::MD5.new
            md5.update (email + DateTime.now().to_s)
            DATABASE[:profiles].update_one({:email => email}, {'$set' => {resetToken: md5.hexdigest}})
            url = 'http://localhost:8080/#/newPassword/' + md5.hexdigest
            sendEmail(
              email,
              'no-reply@wernextgeneration.org',
              'WeRNextGeneration - Password Reset',
              'Click on the following link to reset your password: #{url}',
              "Follow the link below to reset your password: <br><br> <a href=\"#{url}\">Reset Password</a>"
            )
            200
          end

          update_password = lambda do
            profile = DATABASE[:profiles].find(:resetToken => params[:resetToken]).first
            if profile && profile[:active]
              password_hash = createPasswordHash(params[:password])
              DATABASE[:profiles].update_one({:resetToken => params[:resetToken]}, {'$set' => {password_hash: password_hash, resetToken: ''}})
              200
            else
              halt 400, "no profile found with that reset token"
            end
          end
 
          app.post '/api/v1/profiles', &create_a_profile
          app.get '/api/v1/profiles/:profile_id', &get_profile_by_id
          app.get '/api/v1/profile/:_id', &get_profile_by_session_token
          app.put '/api/v1/profiles/:id', &update_profile_role
          app.post '/api/v1/profile/edit/:id', &update_profile
          app.delete '/api/v1/profiles/:_id', &delete_profile
          app.put '/api/v1/profiles/activate/:_id', &activate_profile
          app.put '/api/v1/profiles/resetPassword', &reset_profile_password
          app.put '/api/v1/profiles/newPassword', &update_password

        end

      end
    end
  end
end