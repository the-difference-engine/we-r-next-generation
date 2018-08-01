module Sinatra
  module WeRNextGenerationApp
    module Routing
      module PageResources

        def self.registered(app)

          get_page_resources = lambda do
            result = DATABASE[:pageresources].find(:name => params[:pagename])

            if result.count.zero?
              404
            else
              json result.first['dataObj']
            end
          end

          update_hero_image = lambda do
              homePage = DATABASE[:pageresources].find({:name => 'homepage'}).first['dataObj']
              heroHistory = homePage['heroHistory']
              heroHistory.pop
              heroHistory.unshift(params['heroImage'])
              json DATABASE[:pageresources].update_one({'name' => 'homepage'}, {'$set' => {'dataObj.heroImage' => params['heroImage'], 'dataObj.heroHistory' => heroHistory}})
          end

          app.get '/api/v1/opportunities', &get_page_resources
          app.get '/api/v1/opportunities', &update_hero_image

        end

      end
    end
  end
end