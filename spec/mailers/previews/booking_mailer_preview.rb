class BookingMailerPreview < ActionMailer::Preview
  def confirmation
    BookingMailer.confirmation(Booking.first)
  end
end
