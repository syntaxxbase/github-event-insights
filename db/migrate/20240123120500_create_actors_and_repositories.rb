class CreateActorsAndRepositories < ActiveRecord::Migration[7.1]
  def change
    create_table :actors do |t|
      t.string :github_id, null: false
      t.string :login, null: false
      t.jsonb :details, default: {}
      t.timestamps
    end
    add_index :actors, :github_id, unique: true
    add_index :actors, :login

    create_table :repositories do |t|
      t.string :github_id, null: false
      t.string :name, null: false
      t.jsonb :details, default: {}
      t.timestamps
    end
    add_index :repositories, :github_id, unique: true
    add_index :repositories, :name
  end
end
