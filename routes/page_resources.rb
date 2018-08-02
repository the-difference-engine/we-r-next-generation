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

          add_partner = lambda do
            homePage = DATABASE[:pageresources].find({:name => 'homepage'}).first['dataObj']
            partners = homePage['partners']
            partners.push(params['partner'])
            json DATABASE[:pageresources].update_one({'name' => 'homepage'}, '$set' => {'dataObj.partners' => partners})
          end

          delete_partner = lambda do
            homePage = DATABASE[:pageresources].find({:name => 'homepage'}).first['dataObj']
            partners = homePage['partners']
            partners.delete_at(params['index'].to_i)
            json DATABASE[:pageresources].update_one({'name' => 'homepage'}, '$set' => {'dataObj.partners' => partners})
          end

          app.get '/api/v1/opportunities', &get_page_resources
          app.get '/api/v1/opportunities', &update_hero_image
          app.put '/api/v1/admin/waiver/:type/update', &update_waiver_info
          app.post '/api/v1/admin/partner/add', &add_partner
          app.post '/api/v1/admin/partner/delete', &delete_partner

        end

      end
    end
  end
end