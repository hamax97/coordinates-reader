class AddNameToVideosAndSizeToVideos < ActiveRecord::Migration[7.0]
  def change
    add_column :videos, :name, :string
    add_column :videos, :size, :string
  end
end
