module Sinatra
  module WeRNextGenerationApp
    module Routing
      module SuccessStories

        def self.registered(app)

          get_all_success_stories = lambda do
            data = []
            DATABASE[:success_stories].find.each do |info|
              data << info.to_h
            end
            json data
          end

          get_success_story = lambda do
            json DATABASE[:success_stories].find(:_id => BSON::ObjectId(params[:_id])).first
          end

          update_success_story = lambda do
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

          create_success_story = lambda do
            newStory = DATABASE[:success_stories].insert_one(params['params'])
            json newStory.inserted_ids[0]
          end

          delete_success_story = lambda do
            if DATABASE[:success_stories].find({:_id => BSON::ObjectId(params[:id])}).first
              DATABASE[:success_stories].delete_one( {_id: BSON::ObjectId(params[:id]) } )
              200
            else
              halt 404
            end
          end

          app.get '/api/v1/successStories', &get_all_success_stories
          app.get '/api/v1/admin/successEdit/:_id', &get_success_story
          app.post '/api/v1/admin/successEdit/:id', &update_success_story
          app.post '/api/v1/admin/successAdd', &create_success_story
          app.delete '/api/v1/admin/successEdit/:id', &delete_success_story

        end

      end
    end
  end
end