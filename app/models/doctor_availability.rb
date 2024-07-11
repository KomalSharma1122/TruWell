class DoctorAvailability < ApplicationRecord
  belongs_to :user
  has_many :time_slots, dependent: :destroy

end
