class Profile
  include Mongoid::Document

  field :full_name, type: String
  field :email, type: String
  field :role, type: String
  field :address, type: String
  field :phone_number, type: String
  field :signature, type: String
  field :camp_id, type: String
  field :status, type: String
end
