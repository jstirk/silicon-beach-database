class CreateQualifications < ActiveRecord::Migration
  def self.up
    # Each Person can have multiple Qualifications against their account
    create_table :qualifications do |t|
      t.integer :person_id
      t.string :degree
      t.integer :organization_id
      t.text :summary
      t.datetime :started_at
      t.datetime :ended_at

      t.timestamps
    end
    
    add_index :qualifications, :person_id
    add_index :qualifications, :organization_id
    add_index :qualifications, :degree
  end

  def self.down
    drop_table :qualifications
  end
end
