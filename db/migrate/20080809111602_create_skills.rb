class CreateSkills < ActiveRecord::Migration
  def self.up
    # Each Person can have multiple Skills against their account
    create_table :skills do |t|
      t.integer :person_id
      t.string :value

      t.timestamps
    end
    add_index :skills, :person_id
    add_index :skills, :value
  end

  def self.down
    drop_table :skills
  end
end
