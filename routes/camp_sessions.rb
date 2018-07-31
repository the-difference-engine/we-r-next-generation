module Sinatra
  module WeRNextGenerationApp
    module Routing
      module CampSessions

        def self.registered(app)
          
          # get all
          app.get '/api/v1/camp/session/get' do
            data=[]
            DATABASE[:camp_sessions].find.each do |camp|
              data << camp.to_h
            end
            json(data)
          end

          # get all, sort by Field Name, default = date_start DESC
          app.get '/api/v1/camp/sessions' do
            data=[]
            DATABASE[:camp_sessions].find.each do |camp|
              data << camp.to_h
            end
            json(data)
          end

          app.post '/api/v1/admin/camp/session/create' do
            newCamp = params['params']
            createdCamp = DATABASE[:camp_sessions].insert_one(newCamp)
            json createdCamp.inserted_ids[0].to_s
          end

          app.put '/api/v1/admin/camp/session/:id/update' do
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

          # delete a camp session
          app.delete '/api/v1/admin/camp/session/:id/delete' do
            if DATABASE[:camp_sessions].find( { _id: BSON::ObjectId(params[:id]) } ).first
              DATABASE[:camp_sessions].delete_one( { _id: BSON::ObjectId(params[:id]) } )
              json true
            else
              json false
            end
          end

          # get list of applicants related to the camp session id (string)
          app.get '/api/v1/admin/camp/session/:id/applicants', :provides => :json do
            data = []
            if params[:id]
              DATABASE[:applications].find(:camp => params[:id]).each do |applicant|
                data << applicant.to_h
              end
              json(data)
            end
          end

          app.get '/api/v1/camp/session/:id', :provides => :json do
            if params[:id]
              data = DATABASE[:camp_sessions].find(:_id => BSON::ObjectId(params[:id])).first
              json data
            else
              json({msg: 'Error: Camp Not Found'})
            end
          end

        end

      end
    end
  end
end