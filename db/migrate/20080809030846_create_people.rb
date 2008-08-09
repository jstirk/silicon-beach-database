class CreatePeople < ActiveRecord::Migration
  def self.up
    create_table :people do |t|
      # Most of these fields are directly from the hCard specification
      t.string :given_name
      t.string :family_name
      t.string :title
      t.string :street_address
      t.string :locality
      t.string :region
      t.string :postal_code
      t.string :country

      t.timestamps
    end
    
    add_index :people, [ :given_name, :family_name ]
    add_index :people, :locality
    add_index :people, :region
    add_index :people, :country
  end

  def self.down
    drop_table :people
  end
end
