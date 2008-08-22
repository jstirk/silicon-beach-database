class AddPersonLatAndLong < ActiveRecord::Migration
  def self.up
    add_column :people, :latitude, :decimal, :precision => 10, :scale => 7
    add_column :people, :longitude, :decimal, :precision => 10, :scale => 7
    add_index :people, [ :latitude, :longitude ]
  end

  def self.down
    remove_column :people, :latitude
    remove_column :people, :longitude
  end
end
