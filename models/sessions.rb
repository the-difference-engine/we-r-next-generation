# frozen_string_literal: true

class Session
  include Mongoid::Document

  field :email, type: String
end
