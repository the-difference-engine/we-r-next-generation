# frozen_string_literal: true

class Waiver
  include Mongoid::Document

  field :application, type: String
  field :applicant, type: String
  field :waiver_form, type: String
  field :signed_by, type: String
  field :signed_date, type: String
end
