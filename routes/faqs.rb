module Sinatra
  module WeRNextGenerationApp
    module Routing
      module FAQs

        def self.registered(app)

          newQuestionParams = ['name', 'email', 'message']

          get_all_faqs = lambda do
            data = []
            DATABASE[:faqs].find.each do |faq|
              data << faq.to_h
            end
            json data
          end

          ask_a_question = lambda do
            if !checkParameters(@params, newQuestionParams)
              halt 400, "the requirements were not met, did not post question to WRNG staff"
            else
              message = @params['message'] + " - Question Submitted By: " + @params['name']
              email = @params['email']
              sendEmail(ENV['faq_email'], email, 'FAQ Submission', message)
            end
          end

          get_faq = lambda do
            json DATABASE[:faqs].find(:_id => BSON::ObjectId(params[:_id])).first
          end

          update_faq = lambda do
            content_type :json
            updatedFaq = params['params']
            DATABASE[:faqs].find(:_id => BSON::ObjectId(params[:id])).
              update_one('$set' => {
                'question' => updatedFaq['question'],
                'answer' => updatedFaq['answer'],
                'category' => updatedFaq['category'],
              },)
            updatedFaq = DATABASE[:faqs].find(:_id => BSON::ObjectId(params[:id])).first.to_h
            json updatedFaq
          end

          delete_faq = lambda do
            if DATABASE[:faqs].find({:_id => BSON::ObjectId(params[:id])}).first
              DATABASE[:faqs].delete_one( {_id: BSON::ObjectId(params[:id]) } )
              halt 200, "faq deleted"
            else
              halt 400, "could not find this faq in the database"
            end
          end

          create_faq = lambda do
            newFaq = DATABASE[:faqs].insert_one(params['params'])
            json newFaq.inserted_ids[0]
          end

          app.get '/api/v1/faq', &get_all_faqs
          app.post '/api/v1/faq', &ask_a_question
          app.get '/api/v1/admin/faqEdit/:_id', &get_faq
          app.post '/api/v1/admin/faqEdit/:id', &update_faq
          app.delete '/api/v1/admin/faqEdit/:id', &delete_faq
          app.post '/api/v1/admin/faqAdd', &create_faq

        end

      end
    end
  end
end