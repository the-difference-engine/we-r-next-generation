module Sinatra
  module WeRNextGenerationApp
    module Routing
      module PageResources

        def self.registered(app)

          # webpage resources

          app.get '/api/v1/resources/:pagename' do
            result = DATABASE[:pageresources].find(:name => params[:pagename])

            if result.count.zero?
              json 0
            else
              json result.first['dataObj']
            end
          end

          app.put '/api/v1/resources/update/heroimage' do
              homePage = DATABASE[:pageresources].find({:name => 'homepage'}).first['dataObj']
              heroHistory = homePage['heroHistory']
              heroHistory.pop
              heroHistory.unshift(params['heroImage'])
              json DATABASE[:pageresources].update_one({'name' => 'homepage'}, {'$set' => {'dataObj.heroImage' => params['heroImage'], 'dataObj.heroHistory' => heroHistory}})
          end

        end

      end
    end
  end
end