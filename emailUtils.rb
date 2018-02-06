require 'aws-sdk-ses'

def sendEmail(to, reply, subject, text, html = false)

  ses = Aws::SES::Client.new(region: 'us-east-1', access_key_id: ENV['access_key_id'], secret_access_key: ENV['secret_access_key'])

  body = {}

  if html
    body['html'] = {data: html}
  else
    body['text'] = {data: text}
  end

  ses.send_email({
    destination: {
      to_addresses: [to]
    },
    message: {
      body: body,
      subject: {data: subject},
    },
    source: 'sender@tde-wrng-dev.samdotcomwasntavailable.com',
    reply_to_addresses: [reply]
  })

end
