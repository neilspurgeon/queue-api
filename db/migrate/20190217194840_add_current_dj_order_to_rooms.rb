class AddCurrentDjOrderToRooms < ActiveRecord::Migration[5.0]
  def change
    add_column :rooms, :current_dj_order, :json, default: [], null: false, index: true
  end
end
