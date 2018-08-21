# frozen_string_literal: true

module Sinatra
  module WeRNextGenerationApp
    module Routing
      module CampSessions
        def self.registered(app)
          get_all_camp_sessions = lambda do
            camps = CampSession.all
            json(camps)
          end

          create_new_camp_session = lambda do
            new_camp = params['params']
            created_camp = CampSession.create(new_camp)
            json(created_camp)
          end

          get_camp_session = lambda do
            camp = CampSession.find(params[:id])
            if camp
              json(camp)
            else
              halt 404, 'No camp found with that ID.'
            end
          end

          update_camp_session = lambda do
            camp = CampSession.find(params[:id])
            params['params']['updated_at'] = DateTime.now
            camp.update_attributes(params['params'])
            json(camp)
          end

          delete_camp_session = lambda do
            camp = CampSession.find(params[:id])
            if camp
              camp.destroy
              json(camp)
            else
              halt 404, 'No camp found with that ID.'
            end
          end

          get_camp_session_applicant_list = lambda do
            json(Application.where(camp: params[:id]))
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
