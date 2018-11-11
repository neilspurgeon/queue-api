class AddPlayingToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :playing, :boolean, :null => false, :default => false
  end
end
