# frozen_string_literal: true

module Sinatra
  module WeRNextGenerationApp
    module Routing
      module Applications
        def self.registered(app)
          create_an_application = lambda do
            application = WRNGApplication.create(params['params'])
            json application
          end

          create_application_with_waiver = lambda do
            application = WRNGApplication.create(params['params']['application'])
            waiver = Waiver.create(params['params']['waiver'])
            waiver.update_attributes(application: application.id)
            json application
          end

          get_type_and_id_of_all_applications = lambda do
            data = []
            all_applications = WRNGApplication.all
            all_waivers = Waiver.all

            all_applications.each do |application|
              app_waiver = all_waivers.find { |waiver| waiver[:application] == params[:id] }

              if application[:type] == 'volunteer' && app_waiver[:id] == :id
                data.push('volunteer')
              elsif application[:type] == 'camper' && app_waiver[:id] == :id
                data.push('camper')
              elsif application[:type] == 'partner' && app_waiver[:id] == :id
                data.push('partner')
              end
            end
            json data
          end

          get_application_and_waiver = lambda do
            application = WRNGApplication.find(params[:id])
            waiver = Waiver.find_by(application: params[:id])
            if application && waiver
              if application && (application[:type] == 'camper' || application[:type] == 'volunteer')
                application['camp_data'] = CampSession.find(application.camp)
              end
              response = {
                application: application,
                waiver: waiver
              }
              json(response)
            else
              halt 404, 'No waiver found with that ID.'
            end
          end

          blank_application_object = {
            submitted: {
              icon: 'fa fa-edit',
              apps: {},
              next: 'pending'
            },
            pending: {
              icon: 'fa fa-clock-o',
              apps: {},
              prev: 'submitted',
              reject: 'not_approved',
              approve: 'approved'
            },
            approved: {
              icon: 'fa fa-check',
              apps: {},
              prev: 'pending'
            },
            not_approved: {
              icon: 'fa fa-times',
              apps: {},
              prev: 'pending',
              next: 'delete'
            }
          }

          get_applications_by_type = lambda do
            type = params[:type]
            applications = Marshal.load(Marshal.dump(blank_application_object))
            sessions = {}

            if type == 'camper'
              CampInfo.each do |camp_session|
                sessions[camp_session[:_id].to_s] = camp_session
              end
            end

            all_apps = WRNGApplication.all.order_by(date_signed: :desc, type: :asc)
            all_apps.each do |application|
              if type == 'all'
                status = application[:status].to_sym
                id = application[:_id].to_s
                applications[status][:apps][id] = application
              elsif application[:type] == type
                status = application[:status].to_sym
                id = application[:_id].to_s
                applications[status][:apps][id] = application
                if application[:type] == 'camper'
                  applications[status][:apps][id]['camp_data'] = sessions[application[:camp]]
                end
              end
            end

            data = {
              'applications' => applications,
              'type' => type
            }
            json(data)
          end

          get_all_applications_by_user = lambda do
            json(WRNGApplication.where(profileId: @profile.id))
          end

          get_application_and_camp_session_info = lambda do
            application = WRNGApplication.find(params[:id])
            if application && (application[:type] == 'camper' || application[:type] == 'volunteer')
              application['camp_data'] = CampSession.find(application.camp)
            end
            json(application)
          end

          update_application_status = lambda do
            new_params = params['params']
            application = WRNGApplication.find(params[:id])

            if application
              application.update_attributes(status: new_params['statusChange'])
              application['camp_data'] = CampSession.find(application.camp) if application[:camp]
              json(application)
            else
              halt 401, 'No application found with that ID.'
            end
          end

          delete_application = lambda do
            application = WRNGApplication.find(params[:id])
            if application
              application.destroy
              json(application)
            else
              halt 401, 'No application found with that ID.'
            end
          end

          app.post '/api/v1/applications', &create_an_application
          app.post '/api/v1/applications/waiver', &create_application_with_waiver
          app.get '/api/v1/profiles/applicationcheck/:id', &get_type_and_id_of_all_applications
          app.get '/api/v1/applications/:id/waiver', &get_application_and_waiver
          app.get '/api/v1/profile/applications', &get_all_applications_by_user

          app.get '/api/v1/admin/applications/:type', &get_applications_by_type
          app.get '/api/v1/admin/applications/app/:id', &get_application_and_camp_session_info
          app.put '/api/v1/admin/applications/status/:id', &update_application_status
          app.delete '/api/v1/admin/applications/:id', &delete_application
        end
      end
    end
  end
end
