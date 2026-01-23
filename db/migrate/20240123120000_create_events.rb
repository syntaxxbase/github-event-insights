class CreateEvents < ActiveRecord::Migration[7.1]
  def change
    create_table :events do |t|
      t.string :github_id, null: false
      t.string :type
      t.jsonb :payload, default: {}
      t.references :actor, index: true
      t.references :repository, index: true

      t.timestamps
    end

    add_index :events, :github_id, unique: true
  end
end
