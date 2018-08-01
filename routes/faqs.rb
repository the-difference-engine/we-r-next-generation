module Sinatra
  module WeRNextGenerationApp
    module Routing
      module FAQs

        def self.registered(app)

            # faq endpoints

          newQuestionParams = ['name', 'email', 'message']

          app.get '/api/v1/faq' do
            data = []
            DATABASE[:faqs].find.each do |faq|
              data << faq.to_h
            end
            json data
          end

          app.post '/api/v1/faq' do
            if !checkParameters(@params, newQuestionParams)
              halt 400, "the requirements were not met, did not post question to WRNG staff"
            else
              message = @params['message'] + " - Question Submitted By: " + @params['name']
              email = @params['email']
              sendEmail(ENV['faq_email'], email, 'FAQ Submission', message)
            end
          end

          # faq edits

          app.get '/api/v1/admin/faqEdit/:_id' do
            json DATABASE[:faqs].find(:_id => BSON::ObjectId(params[:_id])).first
          end

          app.post '/api/v1/admin/faqEdit/:id' do
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

          app.delete '/api/v1/admin/faqEdit/:id' do
            if DATABASE[:faqs].find({:_id => BSON::ObjectId(params[:id])}).first
              DATABASE[:faqs].delete_one( {_id: BSON::ObjectId(params[:id]) } )
              halt 200, "faq deleted"
            else
              halt 400, "could not find this faq in the database"
            end
          end

          app.post '/api/v1/admin/faqAdd' do
            newFaq = DATABASE[:faqs].insert_one(params['params'])
            json newFaq.inserted_ids[0]
          end

        end

      end
    end
  end
end