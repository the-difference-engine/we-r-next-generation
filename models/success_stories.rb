# frozen_string_literal: true

class SuccessStory
  include Mongoid::Document

  field :about, type: String
  field :learned, type: String
  field :image, type: String
  field :artwork, type: String
  field :name, type: String
end
