class CreateOrganizations < ActiveRecord::Migration
  def self.up
    # Experiences and Education is done at an Organization
    create_table :organizations do |t|
      t.string :name
      t.text :details

      t.timestamps
    end
    add_index :organizations, :name
  end

  def self.down
    drop_table :organizations
  end
end
