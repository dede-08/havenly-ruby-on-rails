class Listing < ApplicationRecord
  belongs_to :host, class_name: "User"
  has_many :bookings, dependent: :destroy
  has_many_attached :photos

  validates :title, :description, :price_per_night, presence: true
  validates :price_per_night, numericality: { greater_than: 0 }
end