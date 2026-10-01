class Review < ApplicationRecord
  belongs_to :booking

  validates :rating, presence: true, inclusion: { in: 1..5 }
  validates :booking_id, uniqueness: true
  validate :booking_must_be_completed

  delegate :guest, :listing, to: :booking

  private

  def booking_must_be_completed
    return if booking.blank?

    unless booking.confirmed? && booking.check_out.past?
      errors.add(:base, "Solo puedes dejar una review después de completar tu estadía")
    end
  end
end