class MedicalHistory < ApplicationRecord
  belongs_to :user

  enum status: {active: 0, past: 1}

  # validates :disease_name, :start_date, presence: true
end

