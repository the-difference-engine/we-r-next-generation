module Sinatra
  module WeRNextGenerationApp
    module Routing
      module CampInfo

        def self.registered(app)

          get_camp_info = lambda do
            data = []
            DATABASE[:camp_info].find.each do |info|
              data << info.to_h
            end
            json data
          end

          app.get '/api/v1/campinfo', &get_camp_info

        end

      end
    end
  end
end