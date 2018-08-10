# frozen_string_literal: true

module Sinatra
  module WeRNextGenerationApp
    module Routing
      module PageResources
        def self.registered(app)
          get_page_resources = lambda do
            if PageResource.find_by(name: params[:pagename])
              json(resource.dataObj)
            else
              halt 404, 'No resource found with that ID.'
            end
          end

          update_hero_image = lambda do
            resource = PageResource.find_by(name: 'homepage')
            homepage = resource.dataObj
            homepage['heroHistory'].unshift(homepage['heroImage'])
            homepage['heroImage'] = params['heroImage']
            updated_resource = resource.update_attributes(
              dataObj: homepage,
              updated_at: DateTime.now
            )
            json(updated_resource)
          end

          update_waiver_form_info = lambda do
            waiver_form = PageResource.find_by(name: "waiver_#{params[:type]}")
            updated_waiver_form = waiver_form.update_attributes(
              dataObj: params['data'],
              updated_at: DateTime.now
            )
            json(updated_waiver_form)
          end

          add_partner = lambda do
            resource = PageResource.find_by(name: 'homepage')
            homepage = resource.dataObj
            homePage['partners'].push(params['partner'])
            updated_resource = resource.update_attributes(
              dataObj: homepage,
              updated_at: DateTime.now
            )
            json(updated_resource)
          end

          delete_partner = lambda do
            resource = PageResource.find_by(name: 'homepage')
            homepage = resource.dataObj
            homePage['partners'].delete_at(params['index'].to_i)
            updated_resource = resource.update_attributes(
              dataObj: homepage,
              updated_at: DateTime.now
            )
            json(updated_resource)
          end

          app.get '/api/v1/resources/:pagename', &get_page_resources
          app.get '/api/v1/resources/update/heroimage', &update_hero_image
          app.put '/api/v1/admin/waiver/:type/update', &update_waiver_form_info
          app.post '/api/v1/admin/partner/add', &add_partner
          app.post '/api/v1/admin/partner/delete', &delete_partner
        end
      end
    end
  end
end
