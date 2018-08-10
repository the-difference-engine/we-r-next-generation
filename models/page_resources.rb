# frozen_string_literal: true

class PageResource
  include Mongoid::Document
  store_in collection: 'pageresources'

  field :name, type: String
  field :partner, type: String
  field :dataObj, type: Hash
  field :updated_at, type: DateTime
end
