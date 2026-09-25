class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum :role, { guest: 0, host: 1 }, default: :guest

  has_many :listings, foreign_key: :host_id, dependent: :destroy
  has_many :bookings, foreign_key: :guest_id, dependent: :destroy
end