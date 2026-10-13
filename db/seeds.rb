# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end

password = ENV.fetch("DEMO_PASSWORD", "password123")

host = User.find_or_create_by!(email: "host@havenly.demo") do |u|
  u.password = password
  u.role = :host
end

guest = User.find_or_create_by!(email: "guest@havenly.demo") do |u|
  u.password = password
end

[
  { title: "Depa en Miraflores", description: "Departamento luminoso con vista al mar, a pasos del malecón.",
    price_per_night: 120, address: "Av. Larco 123, Miraflores, Lima", latitude: -12.1211, longitude: -77.0296 },
  { title: "Loft en Barranco", description: "Loft moderno en el corazón bohemio de Barranco.",
    price_per_night: 75, address: "Jr. Domeyer 250, Barranco, Lima", latitude: -12.1405, longitude: -77.0213 },
  { title: "Casa en Cusco", description: "Casa con patio interior, cerca de la Plaza de Armas.",
    price_per_night: 90, address: "Calle Plateros 345, Cusco", latitude: -13.5164, longitude: -71.9785 }
].each do |attrs|
  Listing.find_or_create_by!(title: attrs[:title], host: host) { |l| l.assign_attributes(attrs) }
end

# Una estadía ya completada con su review, para que se vea el promedio de rating
listing = Listing.find_by!(title: "Depa en Miraflores")
past_booking = Booking.find_or_create_by!(listing: listing, guest: guest, check_in: Date.current - 30) do |b|
  b.check_out = Date.current - 26
  b.status = :confirmed
  b.total_price = 480
end
Review.find_or_create_by!(booking: past_booking) do |r|
  r.rating = 5
  r.comment = "Excelente ubicación y muy limpio. Volvería sin dudarlo."
end
