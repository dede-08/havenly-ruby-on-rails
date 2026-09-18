class CreateListings < ActiveRecord::Migration[8.1]
  def change
    create_table :listings do |t|
      t.string :title
      t.text :description
      t.decimal :price_per_night
      t.string :address
      t.float :latitude
      t.float :longitude
      t.references :host, null: false, foreign_key: { to_table: :users }

      t.timestamps
    end
  end
end
