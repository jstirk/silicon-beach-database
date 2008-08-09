class CreateUrls < ActiveRecord::Migration
  def self.up
    # Each Person can have multiple URLs against their account
    create_table :urls do |t|
      t.integer :person_id
      t.string :description
      t.string :url

      t.timestamps
    end
    
    add_index :urls, :person_id
    add_index :urls, :url
  end

  def self.down
    drop_table :urls
  end
end
