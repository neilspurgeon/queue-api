class AddColumnsToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :max_djs, :integer, :null => false, :default => 3
    add_column :rooms, :description, :text
    add_column :rooms, :private, :boolean, :null => false, :default => false
    add_column :rooms, :recently_played, :json
  end
end
