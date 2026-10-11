# Preview all emails at http://localhost:3000/rails/mailers/booking_mailer_mailer
class BookingMailerPreview < ActionMailer::Preview

  # Preview this email at http://localhost:3000/rails/mailers/booking_mailer_mailer/confirmation
  def confirmation
    BookingMailer.confirmation
  end

end
