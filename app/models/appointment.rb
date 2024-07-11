class Appointment < ApplicationRecord
  # belongs_to :user
  belongs_to :time_slot
  belongs_to :patient, class_name: 'User', foreign_key: 'patient_id'
  belongs_to :doctor, class_name: 'User', foreign_key: 'doctor_id'

  enum status: {upcoming: 0, completed: 1, not_attended: 2}

  has_many :prescriptions, dependent: :destroy

end

