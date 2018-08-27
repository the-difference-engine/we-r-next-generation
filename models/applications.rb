# frozen_string_literal: true

class WRNGApplication
  include Mongoid::Document
  store_in collection: 'applications'

  field :full_name, type: String
  field :email, type: String
  field :type, type: String
  field :address_line_1, type: String
  field :address_line_2, type: String
  field :city, type: String
  field :state_province, type: String
  field :zip_code, type: String
  field :country, type: String
  field :phone_number, type: String
  field :bio, type: String
  field :camp, type: String
  field :date_signed, type: String
  field :status, type: String
  field :childName, type: String
  field :age, type: String
  field :gender, type: String
  field :companyName, type: String
  field :companyLogo, type: String
  field :companyUrl, type: String
  field :appNote, type: String
  field :profileId, type: BSON::ObjectId
end
