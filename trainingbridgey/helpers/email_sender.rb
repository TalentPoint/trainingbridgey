require 'sinatra/base'
require 'json'
require 'active_support/all'

module Sinatra
  module EmailSender
    def send_gdpr_email(p)
      sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
      file_location = helper_dir + '/../public/docs/terms.docx'
      data = JSON.parse(gdpr_email_data(p, file_location))
      response = sg.client.mail._('send').post(request_body: data)
    end

    def send_email_to_instructor(mapped_data, params)
      sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
      data = JSON.parse(instructor_email_data(params, mapped_data))
      response = sg.client.mail._('send').post(request_body: data)
    end

    private

    def gdpr_email_data(p, file)
      '{
         "content": [
           {
             "type": "text/html",
             "value": "<html><p>Hi ' + p['firstName'] + ',</p><p> Thanks for speaking to us and for signing up with Talent Point.</p>'\
             '<p> Attached are the Terms & Conditions associated with signing up with us. It broadly just sums up the details you spoke about with ' + first_name(params['thisUser']) + ' on the phone earlier. </p>'\
             '<p> If you have any further questions, concerns or other feedback, do not hesitate to contact us at ' + create_email_address(p['thisUser']) + ' and we will reply as soon as possible.</p></html>"
           }
         ],
         "from": {
           "email": "info@talentpoint.co",
           "name": "Talent Point"
         },
         "mail_settings": {
           "footer": {
             "enable": true,
             "html": "<p>Thanks,</br> The Talent Point Team</p>",
             "text": "Thanks,/n The Talent Point Team"
           }
         },
          "attachments": [
            {
              "content": "' + encode_from_file_location(file) + '",
              "filename": "terms.docx",
              "name": "Terms",
              "type": "docx"
            }
          ],
         "personalizations": [
           {
             "cc": [
               {
                 "email": "' + create_email_address(p['thisUser']) + '",
                 "name": "' + user_name(p['thisUser']) + '"
               }
             ],
             "subject": "Welcome to Talent Point!",
             "to": [
               {
                 "email": "' + p["emailAddress"] + '",
                 "name": "'+ p["firstName"] + " " + p["lastName"] +'"
               }
             ]
           }
         ]
       }'
    end

    def instructor_email_data(params, p)
      '{
         "content": [
           {
             "type": "text/html",
             "value": "<html>' + htmlify(params, p) + '</html>"
           }
         ],
         "from": {
           "email": "bridgey@talentpoint.com",
           "name": "TrainingBridgey"
         },
          "attachments": [
            {
              "content": "' + p[:OriginalCvFileData] + '",
              "filename": "CV' + p[:OriginalCvExtension] + '",
              "name": "CV",
              "type": "' + p[:OriginalCvExtension] + '"
            }
          ],
         "personalizations": [
           {
             "subject": "Bridging of ' + p[:FirstName] + " " + p[:LastName] + '",
             "cc": [
               {
                 "email": "' + create_email_address(params['thisUser']) + '",
                 "name": "' + user_name(params['thisUser']) + '"
               }
             ],
             "to": [
               {
                 "email": "daniel.wells@talentpoint.co",
                 "name": "Dan Wells"
               }
             ]
           }
         ]
       }'
    end

    def create_email_address(user)
      name = extract_name(user)
      "#{name[1].downcase}.#{name[2].downcase}@talentpoint.co"
    end

    def first_name(user)
      name = extract_name(user)
      name[1]
    end

    def extract_name(user)
      user = user.split(",")
    end
  end
  helpers EmailSender
end
