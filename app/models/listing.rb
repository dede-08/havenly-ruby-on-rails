class Listing < ApplicationRecord
  belongs_to :host, class_name: "User"
  has_many :bookings, dependent: :destroy
  has_many :reviews, through: :bookings
  has_many_attached :photos
  reverse_geocoded_by :latitude, :longitude

  validates :title, :description, :price_per_night, presence: true
  validates :price_per_night, numericality: { greater_than: 0 }

  def self.ransackable_attributes(auth_object = nil)
    %w[title description price_per_night address created_at]
  end

  def self.ransackable_associations(auth_object = nil)
    []
  end

  scope :available_between, ->(check_in, check_out) {
    return all if check_in.blank? || check_out.blank?

    conflicting_listing_ids = Booking
      .where.not(status: :cancelled)
      .where("check_in < ? AND check_out > ?", check_out, check_in)
      .select(:listing_id)

    where.not(id: conflicting_listing_ids)
  }

  def average_rating
    reviews.average(:rating)&.round(1)
  end
end