class Listing < ApplicationRecord
  belongs_to :host, class_name: "User"

  validates :title, :description, :price_per_night, presence: true
  validates :price_per_night, numericality: { greater_than: 0 }
end