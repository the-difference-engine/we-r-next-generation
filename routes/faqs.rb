# frozen_string_literal: true

module Sinatra
  module WeRNextGenerationApp
    module Routing
      module FAQs
        def self.registered(app)
          new_question_params = %w[name email message]

          get_all_questions = lambda do
            json(FAQ.all)
          end

          ask_a_question = lambda do
            if !check_parameters(@params, new_question_params)
              halt 400, 'the requirements were not met, did not post question to WRNG staff'
            else
              message = "#{@params['message']} - Question Submitted By: #{@params['name']}"
              email = @params['email']
              send_email(
                ENV['faq_email'],
                email,
                'FAQ Submission',
                message
              )
            end
          end

          create_faq = lambda do
            created_question = FAQ.create(params['params'])
            json(created_question)
          end

          get_question = lambda do
            json(FAQ.find(params[:id]))
          end

          update_question = lambda do
            question = FAQ.find(params[:id])
            if question
              updated_question = question.update_attributes(params['params'])
              json(updated_question)
            else
              halt 404, 'No FAQ found with that ID.'
            end
          end

          delete_question = lambda do
            question = FAQ.find(params[:id])
            if question
              question.destroy
              json(question)
            else
              halt 404, 'No FAQ found with that ID.'
            end
          end

          app.get '/api/v1/faq', &get_all_questions
          app.post '/api/v1/faq', &ask_a_question
          app.get '/api/v1/admin/faqEdit/:id', &get_question
          app.post '/api/v1/admin/faq', &create_faq
          app.post '/api/v1/admin/faqEdit/:id', &update_question
          app.delete '/api/v1/admin/faqEdit/:id', &delete_question
          app.post '/api/v1/admin/faqAdd', &create_question
        end
      end
    end
  end
end
