# frozen_string_literal: true

class Profile
  include Mongoid::Document

  field :full_name, type: String
  field :email, type: String
  field :password_hash, type: String
  field :reset_token, type: String
  field :role, type: String
  field :address1, type: String
  field :address2, type: String
  field :city, type: String
  field :state_province, type: String
  field :country, type: String
  field :zip_code, type: String
  field :phone_number, type: String
  field :signature, type: String
  field :camp_id, type: String
  field :status, type: String
  field :active, type: Boolean
end
