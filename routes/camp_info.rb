# frozen_string_literal: true

module Sinatra
  module WeRNextGenerationApp
    module Routing
      module CampInfo
        def self.registered(app)
          get_all_camp_infos = lambda do
            json(CampInfo.all)
          end

          app.get '/api/v1/campinfo', &get_all_camp_infos
        end
      end
    end
  end
end
