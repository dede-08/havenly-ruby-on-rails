class Booking < ApplicationRecord
  belongs_to :listing
  belongs_to :guest, class_name: "User"

  after_create_commit -> { broadcast_prepend_to listing.host, target: "bookings", partial: "bookings/notification", locals: { booking: self } }
  after_update_commit -> { broadcast_replace_to listing.host, target: "booking_#{id}", partial: "bookings/notification", locals: { booking: self } }

  enum :status, { pending: 0, confirmed: 1, cancelled: 2 }, default: :pending

  validates :check_in, :check_out, presence: true
  validate :check_out_after_check_in
  validate :no_overlapping_bookings, on: :create
  has_one :review, dependent: :destroy

  # Scope clave: encuentra reservas de un listing que se crucen con un rango de fechas dado.
  # Dos rangos [a, b] y [c, d] se solapan si a < d y c < b.
  scope :overlapping, ->(listing_id, check_in, check_out) {
    where(listing_id: listing_id)
      .where.not(status: :cancelled)
      .where("check_in < ? AND check_out > ?", check_out, check_in)
  }

  private

  def check_out_after_check_in
    return if check_in.blank? || check_out.blank?

    if check_out <= check_in
      errors.add(:check_out, "debe ser posterior a la fecha de check-in")
    end
  end

  def no_overlapping_bookings
    return if listing_id.blank? || check_in.blank? || check_out.blank?

    conflicts = Booking.overlapping(listing_id, check_in, check_out)
    conflicts = conflicts.where.not(id: id) if persisted?

    if conflicts.exists?
      errors.add(:base, "Ya existe una reserva para estas fechas")
    end
  end
end