# frozen_string_literal: true

class CampSession
  include Mongoid::Document
  include Mongoid::Timestamps

  field :name, type: String
  field :date_start, type: String
  field :date_end, type: String
  field :description, type: String
  field :poc, type: String
  field :limit, type: Integer
  field :status, type: String
  field :created_by, type: BSON::ObjectId
end
