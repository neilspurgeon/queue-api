class CreateTracks < ActiveRecord::Migration[5.0]
  def change
    create_table :tracks do |t|
      t.references :user, foreign_key: true
      t.json :track
      t.boolean :played, :null => false, :default => false

      t.timestamps
    end
  end
end
