# frozen_string_literal: true

module Sinatra
  module WeRNextGenerationApp
    module Routing
      module Friends
        def self.registered(app)
          get_all_friends = lambda do
            json(Friend.all)
          end

          delete_friend = lambda do
            friend = Friend.find(params[:id])
            halt 404, 'No friend found with that ID.' unless friend
            friend.destroy
            json(friend)
          end

          create_friend = lambda do
            new_friend = Friend.create(params['params'])
            json(new_friend)
          end

          update_friend = lambda do
            puts params
            friend = Friend.find(params[:id])
            friend.update_attributes(params['params'])
            json(friend)
          end

          app.get '/api/v1/friends', &get_all_friends

          app.delete '/api/v1/admin/friends/:id', &delete_friend

          app.post '/api/v1/admin/friends', &create_friend

          app.put '/api/v1/admin/friends/:id', &update_friend
        end
      end
    end
  end
end
