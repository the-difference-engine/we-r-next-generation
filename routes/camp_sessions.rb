module Sinatra
  module WeRNextGenerationApp
    module Routing
      module CampSessions

        def self.registered(app)
          
          get_all_camp_sessions = lambda do
            data=[]
            DATABASE[:camp_sessions].find.each do |camp|
              data << camp.to_h
            end
            json(data)
          end

          create_new_camp_session = lambda do
            newCamp = params['params']
            createdCamp = DATABASE[:camp_sessions].insert_one(newCamp)
            json createdCamp.inserted_ids[0].to_s
          end

          update_camp_session = lambda do
            content_type :json
            updatedCamp = params['params']
            DATABASE[:camp_sessions].find(:_id => BSON::ObjectId(params[:id])).
              update_one('$set' => {
                'name' => updatedCamp['name'],
                'date_start' => updatedCamp['date_start'],
                'date_end' => updatedCamp['date_end'],
                'description' => updatedCamp['description'],
                'poc' => updatedCamp['poc'],
                'limit' => updatedCamp['limit'],
                'status' => updatedCamp['status']
              }, '$currentDate' => { 'updated_at' => true })
            updatedCamp = DATABASE[:camp_sessions].find(:_id => BSON::ObjectId(params[:id])).first.to_h
            json updatedCamp
          end

          delete_camp_session = lambda do
            if DATABASE[:camp_sessions].find( { _id: BSON::ObjectId(params[:id]) } ).first
              DATABASE[:camp_sessions].delete_one( { _id: BSON::ObjectId(params[:id]) } )
              json true
            else
              json false
            end
          end

          get_camp_session_applicant_list = lambda do
            data = []
            if params[:id]
              DATABASE[:applications].find(:camp => params[:id]).each do |applicant|
                data << applicant.to_h
              end
              json(data)
            end
          end

          get_camp_session = lambda do
            if params[:id]
              data = DATABASE[:camp_sessions].find(:_id => BSON::ObjectId(params[:id])).first
              json data
            else
              json({msg: 'Error: Camp Not Found'})
            end
          end

          app.get '/api/v1/camp/session/get', &get_all_camp_sessions
          app.get '/api/v1/camp/sessions', &get_all_camp_sessions
          app.post '/api/v1/admin/camp/session/create', &create_new_camp_session
          app.put '/api/v1/admin/camp/session/:id/update', &update_camp_session
          app.delete '/api/v1/admin/camp/session/:id/delete', &delete_camp_session
          app.get '/api/v1/admin/camp/session/:id/applicants', &get_camp_session_applicant_list
          app.get '/api/v1/camp/session/:id', &get_camp_session

        end

      end
    end
  end
end