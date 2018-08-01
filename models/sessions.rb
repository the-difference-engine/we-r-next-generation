class Session
  include Mongoid::Document

  field :email, type: String
end