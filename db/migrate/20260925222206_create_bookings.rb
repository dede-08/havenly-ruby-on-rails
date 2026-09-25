class CreateBookings < ActiveRecord::Migration[8.1]
  def change
    create_table :bookings do |t|
      t.references :listing, null: false, foreign_key: true
      t.references :guest, null: false, foreign_key: { to_table: :users }
      t.date :check_in, null: false
      t.date :check_out, null: false
      t.integer :status, null: false, default: 0
      t.decimal :total_price, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end