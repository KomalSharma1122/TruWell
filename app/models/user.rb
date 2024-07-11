class User < ApplicationRecord
  rolify
  has_secure_password

  has_one :user_address, dependent: :destroy
  has_one :emergency_contact_detail, dependent: :destroy
  has_one :doctor_information, dependent: :destroy
  has_many :doctor_availabilities, dependent: :destroy
  has_one :hospital, dependent: :destroy
  has_many :appointments, dependent: :destroy
  has_many :medical_histories, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :chat_rooms, dependent: :destroy
  has_attached_file :profile_pic

  enum gender: {male: 0, female: 1}
  enum status: {active: 0, blocked: 1}

  validates :first_name, :last_name, :email, :phone_no, presence: true
  validates :email, uniqueness: {message: "is taken before", case_sensitive: true}, format: {with: /\A[a-zA-Z0-9_]+@[a-zA-Z]+\.[a-zA-Z]+\z/}
  validates :first_name, format: {with: /\A[A-Za-z]+\z/, message: "can contain only alphabets"}
  validates :last_name, format: {with: /\A[A-Za-z]+\z/, message: "can contain only alphabets"}
  validates :phone_no, format: {with: /\A\d+\z/}, length: {is: 10}, uniqueness: true
  validates :password, length: {minimum: 8}, format: {with: /\A(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[^A-Za-z\d]).*\z/}, presence: true, if: :password_changed?
  validates :gender,  inclusion: { in: genders, message: "%{value} is not a valid gender"}

  # accepts_nested_attributes_for :user_addresses
  # accepts_nested_attributes_for :emergency_contact_details

end

