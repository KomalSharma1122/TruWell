class EmergencyContactDetail < ApplicationRecord
  belongs_to :user

  # validates :name, :phone_no, :relation, presence: true

  # validates :phone_no, format: {with: /\A\d+\z/}, length: {is: 10}

  # validates :name, format: {with: /\A[A-Za-z]+\z/, message: "can contain only alphabets"}

end
