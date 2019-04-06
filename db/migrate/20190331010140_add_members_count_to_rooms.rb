class AddMembersCountToRooms < ActiveRecord::Migration[5.2]
  def change
    add_column :rooms, :memberships_count, :integer, :default => 0
  end
end
