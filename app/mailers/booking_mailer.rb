class BookingMailer < ApplicationMailer
  def confirmation(booking)
    @booking = booking
    mail(
      to: booking.guest.email,
      subject: "Tu reserva en #{booking.listing.title} está confirmada"
    )
  end
end