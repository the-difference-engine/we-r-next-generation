# frozen_string_literal: true

module Sinatra
  module WeRNextGenerationApp
    module Routing
      module Opportunities
        def self.registered(app)
          get_all_opportunities = lambda do
            json(Opportunity.all)
          end

          app.get '/api/v1/opportunities', &get_all_opportunities
        end
      end
    end
  end
end
