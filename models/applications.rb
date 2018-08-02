class Application
  include Mongoid::Document

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
end