class AddVideoFkToImages < ActiveRecord::Migration[7.0]
  def change
    add_reference :images, :video, foreign_key: true, null: false
  end
end
