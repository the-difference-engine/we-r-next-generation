module Sinatra
  module WeRNextGenerationApp
    module Routing
      module Applications

        def self.registered(app)
          
          create_an_application = lambda do
            app = DATABASE[:applications].insert_one(params['params'])
            json app.inserted_ids[0]
          end

          attach_waiver_to_application = lambda do
            app = DATABASE[:applications].insert_one(params['params']['application'])
            app_id = app.inserted_ids[0].to_s
            waiver = params['params']['waiver']
            waiver['application'] = app_id
            waiver = DATABASE[:waivers].insert_one(waiver)
            json app_id
          end

          get_type_and_id_of_all_applications = lambda do
            data = []
            DATABASE[:application].find.each do |app|
              waiver = DATABASE[:waivers].find(:application => params[:id]).first
              check = waiver[:id]
              if app[:type] == 'volunteer' && :id == waiver[:id]
                data.push('volunteer')
              end
              if app[:type] == 'camper' && :id == waiver[:id]
                data.push('camper')
              end
              if app[:type] == 'partner' && :id == waiver[:id]
                data.push('partner')
              end
            end
            json data
          end

          get_application_waiver = lambda do
            if params[:id]
              data = DATABASE[:waivers].find(:application => params[:id]).first
              json data
            else
              json({msg: 'Error: Waiver Not Found'})
            end
          end

          get_applications_by_type = lambda do
            type = params[:type]
            applications = {
              submitted: {
                :icon => 'fa fa-edit',
                :apps => {},
                :next => 'pending'
              },
              pending: {
                :icon => 'fa fa-clock-o',
                :apps => {},
                :prev => 'submitted',
                :reject => 'not_approved',
                :approve => 'approved'
              },
              approved: {
                :icon => 'fa fa-check',
                :apps => {},
                :prev => 'pending'
              },
              not_approved: {
                :icon => 'fa fa-times',
                :apps => {},
                :prev => 'pending',
                :next => 'delete'
              }
            }
            sessions = {}
            if type === 'camper'
              DATABASE[:camp_sessions].find.each do |session|
                sessions[session[:_id].to_s] = session.to_h
              end
            end

            DATABASE[:applications].find.each do |application|
              if type === 'all'
                status = application[:status].to_sym
                id = application[:_id].to_s
                applications[status][:apps][id] = application.to_h
              elsif application[:type] == type
                status = application[:status].to_sym
                id = application[:_id].to_s
                applications[status][:apps][id] = application.to_h
                if application[:type] === 'camper'
                  applications[status][:apps][id]['camp_data'] = sessions[application[:camp]]
                end
              end
            end

              return {"applications" => applications, "type" => type}.to_json
          end

          get_application_and_camp_session_info = lambda do
            application = DATABASE[:applications].find({'_id' => BSON::ObjectId(params[:id])}).first
            if application && (application[:type] === 'camper' || application[:type] === 'volunteer')
              application[:camp_data] = DATABASE[:camp_sessions].find({'_id' => BSON::ObjectId(application[:camp])}).first
            end
             json application
          end

          update_application_status = lambda do
            id = params[:id]
            newParams = params['params']
            application = DATABASE[:applications].find({'_id' => BSON::ObjectId(id)}).first

            if application
              DATABASE[:applications].update_one({'_id' => BSON::ObjectId(id)}, {'$set' => {status: newParams['statusChange']}})
              newApplication = DATABASE[:applications].find({'_id' => BSON::ObjectId(id)}).first
              if application[:camp]
                newApplication['camp_data'] = DATABASE[:camp_sessions].find({'_id' => BSON::ObjectId(application[:camp])}).first
              end
              json newApplication
            else
              halt 400, "could not find this application in the database"
            end
          end

          delete_application = lambda do
            if DATABASE[:applications].find({:_id => BSON::ObjectId(params[:id])}).first
              DATABASE[:applications].delete_one( {_id: BSON::ObjectId(params[:id]) } )
              halt 200, "record deleted"
            else
              halt 400, "could not find this application in the database"
            end
          end

          app.post '/api/v1/applications', &create_an_application
          app.post '/api/v1/applications/waiver', &attach_waiver_to_application
          app.get '/api/v1/profiles/applicationcheck/:id', &get_type_and_id_of_all_applications
          app.get '/api/v1/applications/:id/waiver', &get_application_waiver

          app.get '/api/v1/admin/applications/:type', &get_applications_by_type
          app.get '/api/v1/admin/applications/app/:id', &get_application_and_camp_session_info
          app.put '/api/v1/admin/applications/status/:id', &update_application_status
          app.delete '/api/v1/admin/applications/:id', &delete_application

        end

      end
    end
  end
end