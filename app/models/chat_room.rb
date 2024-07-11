class ChatRoom < ApplicationRecord
  belongs_to :user, class_name: 'User', foreign_key: 'doctor_id'
  belongs_to :user, class_name: 'User', foreign_key: 'patient_id'
  has_many :messages, dependent: :destroy

  enum status: {active: 0, inactive: 1, favourite: 3}

end
