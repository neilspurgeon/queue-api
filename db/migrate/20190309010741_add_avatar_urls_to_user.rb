class AddAvatarUrlsToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :avatar_urls, :json, default: [], null: false
  end
end
