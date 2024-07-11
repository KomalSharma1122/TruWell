class DoctorInformation < ApplicationRecord
  belongs_to :user

  # validates :language, :specialization, :about, :charges, presence: true

end
