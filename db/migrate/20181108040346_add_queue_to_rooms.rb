class AddQueueToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :queue, :json
    add_column :rooms, :current_track, :json
  end
end
