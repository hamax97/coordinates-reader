class CreateImages < ActiveRecord::Migration[7.0]
  def change
    create_table :images do |t|
      t.string :name, null: false
      t.integer :size
      t.float :latitude
      t.float :longitude
      t.string :extracted_text

      t.timestamps
    end
  end
end
