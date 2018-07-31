module Sinatra
  module WeRNextGenerationApp
    module Routing
      module SuccessStories

        def self.registered(app)

          # Success Stories

          app.get '/api/v1/successStories' do
            data = []
            DATABASE[:success_stories].find.each do |info|
              data << info.to_h
            end
            json data
          end

          # success Edits

          app.get '/api/v1/admin/successEdit/:_id' do
            json DATABASE[:success_stories].find(:_id => BSON::ObjectId(params[:_id])).first
          end

          app.post '/api/v1/admin/successEdit/:id' do
            content_type :json
            updatedStory = params['params']
            DATABASE[:success_stories].find(:_id => BSON::ObjectId(params[:id])).
              update_one('$set' => {
                'name' => updatedStory['name'],
                'about' => updatedStory['about'],
                'learned' => updatedStory['learned'],
                'image' => updatedStory['image'],
                'artwork' => updatedStory['artwork'],
              },)
            updatedStory = DATABASE[:success_stories].find(:_id => BSON::ObjectId(params[:id])).first.to_h
            json updatedStory
          end

          app.post '/api/v1/admin/successAdd' do
            newStory = DATABASE[:success_stories].insert_one(params['params'])
            json newStory.inserted_ids[0]
          end

          app.delete '/api/v1/admin/successEdit/:id' do
            if DATABASE[:success_stories].find({:_id => BSON::ObjectId(params[:id])}).first
              DATABASE[:success_stories].delete_one( {_id: BSON::ObjectId(params[:id]) } )
              halt 200, "success story deleted"
            else
              halt 400, "could not find this success story in the database"
            end
          end

        end

      end
    end
  end
end