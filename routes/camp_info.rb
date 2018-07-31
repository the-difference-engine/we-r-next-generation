module Sinatra
  module WeRNextGenerationApp
    module Routing
      module CampInfo

        def self.registered(app)

          # camp info endpoints

          app.get '/api/v1/campinfo' do
            data = []
            DATABASE[:camp_info].find.each do |info|
              data << info.to_h
            end
            json data
          end

        end

      end
    end
  end
end