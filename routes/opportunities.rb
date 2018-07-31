module Sinatra
  module WeRNextGenerationApp
    module Routing
      module Opportunities

        def self.registered(app)

          # opportunities endpoints

          app.get '/api/v1/opportunities' do
            data = []
            DATABASE[:opportunities].find.each do |info|
              data << info.to_h
            end
            json data
          end

        end

      end
    end
  end
end