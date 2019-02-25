class CreateDjs < ActiveRecord::Migration[5.2]
  def change
    create_table :dj_memberships do |t|
      t.references :user, foreign_key: true
      t.references :room, foreign_key: true
      t.timestamps
    end
  end
end
