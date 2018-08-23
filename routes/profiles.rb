# frozen_string_literal: true

module Sinatra
  module WeRNextGenerationApp
    module Routing
      module Profiles
        def self.registered(app)
          profile_params = %w[full_name address1 city state_province country zip_code phone_number email active role password_hash]
          signup_params = %w[name address1 city state_province country zip_code phone_number email password password_hash]

          get_all_profiles = lambda do
            json(Profile.all)
          end

          create_a_profile = lambda do
            profile = params[:newUser]
            profile['password_hash'] = create_password_hash(profile[:password])
            if !check_signup_parameters(profile, signup_params)
              halt 400, 'Parameter requirements were not met.'
            elsif Profile.find_by(email: profile['email'])
              halt 400, 'A profile with this email address already exists.'
            else
              profile[:full_name] = profile.delete :name
              profile['active'] = true
              profile.delete('password')
              profile.delete('password_confirm')
              profile = Profile.create(profile)
              url = 'http://wernextgeneration.org/#/confirmation/' + profile.id
              send_email(
                to_addresses_array: [profile.email],
                reply_addresses_array: ['no-reply@wernextgeneration.org'],
                subject: 'WeRNextGeneration - Sign Up Confirmation',
                text: "Navigate to this link to activate your account: #{url}",
                html: "Follow the link below to activate your account: <br><br> <a href=\"#{url}\">Activate Account</a>"
              )
              json(profile)
            end
          end

          get_profile_by_id = lambda do
            json(Profile.find(params[:profile_id]))
          end

          get_profile_by_session_token = lambda do
            if params[:session_token] != @token
              halt(401, 'Invalid Token')
            else
              profile = Profile.find_by(email: Session.find(params[:session_token]).email)
              json(profile)
            end
          end

          update_profile = lambda do
            updatedProfile = params[:updatedProfile]
            if !@profile || @profile[:id].to_s != updatedProfile[:_id][:$oid].to_s
              if @profile[:role] != 'superadmin'
                halt 400, 'Permission Denied.' unless check_parameters(params, profile_params)
              end
            end
            if !check_parameters(updatedProfile, profile_params)
              halt 400, 'Parameter requirements were not met.'
            else
              if updatedProfile[:change_password] == true
                if !check_password(@profile[:password_hash], updatedProfile[:oldPassword])
                  halt 400, 'Invalid Credentials. Permission Denied.'
                end
                new_hashed = update_password(updatedProfile[:_id][:$oid], updatedProfile[:newPassword])
                updatedProfile[:password_hash] = new_hashed
              end
              updatedProfile.delete('change_password')
              updatedProfile.delete('oldPassword')
              updatedProfile.delete('newPassword')
              profile = Profile.find(updatedProfile[:_id][:$oid])
              profile.update_attributes(updatedProfile)
              json(profile)
            end
          end

          delete_profile = lambda do
            profile = Profile.find(params[:id])
            if profile
              profile.destroy
              json(profile)
            else
              halt 404, 'No profile found with that ID.'
            end
          end

          activate_profile = lambda do
            profile = Profile.find(params[:id])
            if profile
              profile.update_attributes(active: true)
              json(profile)
            else
              halt 404, 'No profile found with that ID.'
            end
          end

          reset_profile_password = lambda do
            profile = Profile.find_by(email: params[:email])

            halt 404, 'No profile found with that email.' if !profile || !profile[:active]

            hex_digest = Digest::SHA256.hexdigest(profile.email + DateTime.now.to_s)
            profile.update_attributes(reset_token: hex_digest)

            url = 'http://wernextgeneration.org/#/updatePassword/' + hex_digest
            send_email(
              to_addresses_array: [profile.email],
              reply_addresses_array: ['no-reply@wernextgeneration.org'],
              subject: 'WeRNextGeneration - Password Reset',
              text: "Click on the following link to reset your password: #{url}",
              html: "Follow the link below to reset your password: <br><br> <a href=\"#{url}\">Reset Password</a>"
            )

            json(profile)
          end

          update_password = lambda do
            profile = Profile.find_by(reset_token: params[:reset_token])
            if profile && profile[:active]
              password_hash = create_password_hash(params[:password])
              profile.update_attributes(password_hash: password_hash, reset_token: nil)
              json(profile)
            else
              halt 404, 'No profile found with that reset token.'
            end
          end

          app.get '/api/v1/profiles', &get_all_profiles
          app.post '/api/v1/profiles', &create_a_profile
          app.get '/api/v1/profiles/:profile_id', &get_profile_by_id
          app.get '/api/v1/profile/:session_token', &get_profile_by_session_token
          app.put '/api/v1/profiles/:id', &update_profile
          app.post '/api/v1/profile/edit/:id', &update_profile
          # app.post '/api/v1/profile/edit/:id/changePassword', &update_old_to_new_password
          app.delete '/api/v1/profiles/:id', &delete_profile
          app.put '/api/v1/profiles/activate/:id', &activate_profile
          app.get '/api/v1/resetPassword/:email', &reset_profile_password
          app.put '/api/v1/updatePassword/:reset_token', &update_password
        end
      end
    end
  end
end
