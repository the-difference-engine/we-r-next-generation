# frozen_string_literal: true

require 'aws-sdk-ses'
require 'bcrypt'

module Sinatra
  module WeRNextGenerationApp
    module Helpers
      def send_email(to_addresses_array:, reply_addresses_array:, subject:, text:, html: false)
        ses = Aws::SES::Client.new(
          region: 'us-east-1',
          access_key_id: ENV['access_key_id'],
          secret_access_key: ENV['secret_access_key']
        )

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

        begin
          email_obj = {
            destination: {
              to_addresses: to_addresses_array
            },
            message: {
              body: body,
              subject: {
                data: subject
              }
            },
            source: 'no-reply@wernextgeneration.org',
            reply_to_addresses: reply_addresses_array
          }
          ses_response = ses.send_email(email_obj)

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
    end
  end
end
