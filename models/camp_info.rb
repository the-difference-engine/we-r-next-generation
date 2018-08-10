# frozen_string_literal: true

class CampInfo
  include Mongoid::Document
  store_in collection: 'campinfo'

  field :title, type: String
  field :content, type: String
end
