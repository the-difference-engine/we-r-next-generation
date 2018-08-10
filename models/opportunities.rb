# frozen_string_literal: true

class Opportunity
  include Mongoid::Document

  field :imgSrc, type: String
  field :imgAlt, type: String
  field :headline, type: String
  field :caption, type: String
  field :callToAct, type: String
end
