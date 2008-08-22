class CreateExperiences < ActiveRecord::Migration
  def self.up
    # Each Person can have multiple Experiences against their account
    create_table :experiences do |t|
      t.integer :person_id
      t.string :title
      t.integer :organization_id
      t.text :summary
      t.datetime :started_at
      t.datetime :ended_at
      t.integer :duration

      t.timestamps
    end
    
    add_index :experiences, :person_id
    add_index :experiences, :organization_id
    add_index :experiences, :title
    add_index :experiences, [ :person_id, :organization_id, :title ]
  end

  def self.down
    drop_table :experiences
  end
end
