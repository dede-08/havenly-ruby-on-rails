require "rails_helper"

RSpec.describe BookingMailer, type: :mailer do
  describe "#confirmation" do
    let(:listing) { create(:listing, title: "Depa en Miraflores") }
    let(:guest) { create(:user, email: "guest@example.com") }
    let(:booking) do
      create(:booking, listing: listing, guest: guest, status: :confirmed,
                       check_in: Date.new(2026, 12, 1), check_out: Date.new(2026, 12, 5),
                       total_price: 480)
    end
    let(:mail) { described_class.confirmation(booking) }

    it "se envía al guest con el título del listing en el asunto" do
      expect(mail.to).to eq([ "guest@example.com" ])
      expect(mail.subject).to eq("Tu reserva en Depa en Miraflores está confirmada")
    end

    it "incluye los datos de la reserva en la versión HTML" do
      html = mail.html_part.body.decoded
      expect(html).to include("Depa en Miraflores", "2026-12-01", "2026-12-05", "480")
    end

    it "incluye los datos de la reserva en la versión de texto" do
      text = mail.text_part.body.decoded
      expect(text).to include("Depa en Miraflores", "2026-12-01", "2026-12-05", "480")
    end
  end
end
