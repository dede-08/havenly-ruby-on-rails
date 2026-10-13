class AddNoOverlapConstraintToBookings < ActiveRecord::Migration[8.1]
  def change
    enable_extension "btree_gist"

    # status 2 = cancelled: las reservas canceladas no bloquean fechas
    add_exclusion_constraint :bookings,
                             "listing_id WITH =, daterange(check_in, check_out, '[)') WITH &&",
                             using: :gist,
                             where: "status <> 2",
                             name: "bookings_no_overlapping_dates"
  end
end
