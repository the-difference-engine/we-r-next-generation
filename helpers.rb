# frozen_string_literal: true

require 'aws-sdk-ses'
require 'bcrypt'

module Sinatra
  module WeRNextGenerationApp
    # Miscellaneous helper functions for the WRNG app
    module Helpers
      SES_CLIENT = Aws::SES::Client.new(
        region: 'us-east-1',
        access_key_id: ENV['access_key_id'],
        secret_access_key: ENV['secret_access_key']
      )

      def set_email_body_content(text, html)
        body = {}

        if html
          body['html'] = {
            data: html
          }
        else
          body['text'] = {
            data: text
          }
        end

        body
      end

      def create_email_object(to_addresses_array, body, subject, source, reply_addresses_array)
        {
          destination: {
            to_addresses: to_addresses_array
          },
          message: {
            body: body,
            subject: {
              data: subject
            }
          },
          source: source,
          reply_to_addresses: reply_addresses_array
        }
      end

      def send_email(to_addresses_array:, reply_addresses_array:, subject:, text:, html: nil)
        body = set_email_body_content(text, html)
        begin
          email_obj = create_email_object(
            to_addresses_array,
            body,
            subject,
            'no-reply@wernextgeneration.org',
            reply_addresses_array
          )
          ses_response = SES_CLIENT.send_email(email_obj)

          ses_response.data.message_id
        rescue
          puts 'ERROR: Failed to send email'
        end
      end

      def create_password_hash(password)
        BCrypt::Password.create(password)
      end

      def check_password(password_hash, password)
        correct_pass = BCrypt::Password.new(password_hash)
        correct_pass.is_password?(password)
      end

      def update_password(profileId, newPassword)
        new_hashed_pw = create_password_hash(newPassword)
        Profile.find(profileId).update(password_hash: new_hashed_pw)
        return new_hashed_pw
      end

      def check_parameters(parameters, required)
        required.each do |req|
          return false unless parameters.include?(req)
        end
        parameters.length >= required.length
      end

      def check_signup_parameters(parameters, required)
        required.each do |req|
          return false if parameters[req] == ''
        end
        parameters.length >= required.length
      end

      def define_token(request)
        header_token = request.env['HTTP_X_TOKEN']
        return header_token unless header_token.nil? || header_token.empty?
        begin
          return request.env['rack.request.form_hash']['headers']['x-token']
        rescue KeyError
          return nil
        end
      end

      def check_token_presence(token)
        halt(401, 'No token received from browser request') if token.nil? || token.empty?
      end

      def check_session_presence(session)
        halt(401, 'Invalid token') if session.nil?
      end

      def check_token_legality(token)
        halt(401, 'Invalid token') unless BSON::ObjectId.legal?(token)
      end

      def check_admin_permissions(request, profile)
        halt(401, 'Minimum admin profile required') if (request.path_info.include? '/admin/') && \
                                                       (!profile || !%w[admin superadmin].include?(profile.role))
      end

      def validate_token(request)
        @token = define_token(request)
        check_token_presence(@token)
        @session = Session.find(id: @token)
        @profile = Profile.find_by(email: @session[:email])
        check_session_presence(@session)
        check_token_legality(@token)
        check_admin_permissions(request, @profile)
        true
      end
    end
  end
end
