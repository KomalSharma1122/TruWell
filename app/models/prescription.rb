class Prescription < ApplicationRecord
  belongs_to :appointment

  # validates :title, :prescription_type, :dosage, :quantity, :medicine, presence: true
end
