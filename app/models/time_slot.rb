class TimeSlot < ApplicationRecord
  belongs_to :doctor_availability
  belongs_to :user
  has_one :appointment, dependent: :destroy

  enum status: {available: 0, booked: 1, completed: 2}
end 