# frozen_string_literal: true

module Sinatra
  module WeRNextGenerationApp
    module Routing
      module SuccessStories
        def self.registered(app)
          get_all_success_stories = lambda do
            json(SuccessStory.all)
          end

          get_success_story = lambda do
            json(SuccessStory.find(params[:id]))
          end

          update_success_story = lambda do
            story = SuccessStory.find(params[:id])
            if story
              story.update_attributes(params['params'])
              json(story)
            else
              halt 404, 'No success story found with that ID.'
            end
          end

          create_success_story = lambda do
            json(SuccessStory.create(params['params']))
          end

          delete_success_story = lambda do
            story = SuccessStory.find(params[:id])
            if story
              story.destroy
              json(story)
            else
              halt 404, 'No success story found with that ID.'
            end
          end

          app.get '/api/v1/successStories', &get_all_success_stories
          app.get '/api/v1/admin/successEdit/:id', &get_success_story
          app.post '/api/v1/admin/successEdit/:id', &update_success_story
          app.post '/api/v1/admin/successAdd', &create_success_story
          app.delete '/api/v1/admin/successEdit/:id', &delete_success_story
        end
      end
    end
  end
end
