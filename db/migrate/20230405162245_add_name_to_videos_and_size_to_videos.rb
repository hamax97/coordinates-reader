class AddNameToVideosAndSizeToVideos < ActiveRecord::Migration[7.0]
  def change
    add_column :videos, :name, :string, null: false
    add_column :videos, :size, :string
  end
end
