require 'aws-sdk-ses'
require 'bcrypt'

module Sinatra
  module WeRNextGenerationApp
    module Helpers

      def sendEmail(to, reply, subject, text, html = false)
        ses = Aws::SES::Client.new(
          region: 'us-east-1',
          access_key_id: ENV['access_key_id'],
          secret_access_key: ENV['secret_access_key']
        )

        body = {}

        if html
          body['html'] = {data: html}
        else
          body['text'] = {data: text}
        end

        begin
          a = ses.send_email({
            destination: {
              to_addresses: [to]
            },
            message: {
              body: body,
              subject: {data: subject},
            },
            source: 'no-reply@wernextgeneration.org',
            reply_to_addresses: [reply]
          })

          a.data.message_id
        rescue
          puts "ERROR: Failed to send email"
        end
      end

      def createPasswordHash (password)
        return BCrypt::Password.create(password)
      end

      def checkPassword (passwordHash, password)
        correctPass = BCrypt::Password.new(passwordHash)
        return correctPass.is_password?(password)
      end

      def checkParameters(parameters, required)
        for reqs in required do
          if !parameters.include?(reqs)
            return false
          end
        end
        return parameters.length == required.length
      end

      def checkSignupParameters(parameters, required)
        for reqs in required do
          if parameters[reqs] === ''
            return false
          end
        end
        return parameters.length == required.length
      end

    end
  end
end