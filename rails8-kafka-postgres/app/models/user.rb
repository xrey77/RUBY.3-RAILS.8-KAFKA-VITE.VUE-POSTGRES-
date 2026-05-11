class User < ApplicationRecord
  belongs_to :role
  has_secure_password
  has_many :sessions, dependent: :destroy
  normalizes :email_address, with: -> e { e.strip.downcase }

  validates :email_address, uniqueness: true, presence: true
  validates :username, uniqueness: true, presence: true  

end
