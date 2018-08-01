module Sinatra
  module WeRNextGenerationApp
    module Routing
      module Waivers

        def self.registered(app)

          update_waiver_info = lambda do
            content_type :json
            waiver_type = "waiver_" + params[:type]
            updated_waiver = params['data']
            waiver = DATABASE[:pageresources].update_one(
              {
                :name => waiver_type
              },
              {
                '$set' => {
                  'dataObj' => updated_waiver
                }, 
                '$currentDate' => { 
                  'updated_at' => true 
                }
              }
            )
            json waiver
          end

          app.put '/api/v1/admin/waiver/:type/update', &update_waiver_info

        end

      end
    end
  end
end