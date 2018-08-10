# frozen_string_literal: true

class FAQ
  include Mongoid::Document

  field :question, type: String
  field :answer, type: String
  field :category, type: String
end
