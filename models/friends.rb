# frozen_string_literal: true

class Friend
  include Mongoid::Document

  field :name, type: String
  field :about, type: String
  field :url, type: String

end
