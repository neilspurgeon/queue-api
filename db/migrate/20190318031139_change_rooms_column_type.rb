class ChangeRoomsColumnType < ActiveRecord::Migration[5.2]
  def change
    change_column :rooms, :recently_played, :json, :default => []
  end
end
