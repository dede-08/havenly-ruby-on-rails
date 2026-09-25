require "rails_helper"

RSpec.describe User, type: :model do
  it "es guest por defecto" do
    user = create(:user)
    expect(user.guest?).to be true
  end

  it "puede ser host" do
    user = create(:user, :host)
    expect(user.host?).to be true
  end

  it "tiene muchos listings cuando es host" do
    host = create(:user, :host)
    listing = create(:listing, host: host)
    expect(host.listings).to include(listing)
  end
end