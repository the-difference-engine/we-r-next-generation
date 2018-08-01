module Sinatra
  module WeRNextGenerationApp
    module Routing
      module Partners

        def self.registered(app)

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

          app.post '/api/v1/admin/partner/add', &add_partner
          app.post '/api/v1/admin/partner/delete', &delete_partner

        end

      end
    end
  end
end