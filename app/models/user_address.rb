class UserAddress < ApplicationRecord
  belongs_to :user

  # validates :line1, :line2, :city, :pincode, presence: true
end

