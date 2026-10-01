class CreateReviews < ActiveRecord::Migration[8.1]
  def change
    create_table :reviews do |t|
      t.references :booking, null: false, foreign_key: true, index: { unique: true }
      t.integer :rating, null: false
      t.text :comment

      t.timestamps
    end
  end
end