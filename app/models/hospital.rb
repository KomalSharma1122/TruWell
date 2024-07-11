class Hospital < ApplicationRecord
  belongs_to :user

  # validates :name, :address, :city, :state, :pincode, presence: true
end

