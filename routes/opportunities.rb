module Sinatra
  module WeRNextGenerationApp
    module Routing
      module Opportunities

        def self.registered(app)

          get_all_opportunities = lambda do
            data = []
            DATABASE[:opportunities].find.each do |info|
              data << info.to_h
            end
            json data
          end

          app.get '/api/v1/opportunities', &get_all_opportunities

        end

      end
    end
  end
end