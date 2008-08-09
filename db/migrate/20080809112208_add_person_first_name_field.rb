class AddPersonFirstNameField < ActiveRecord::Migration
  def self.up
    # Because we need to account for folks with non-Western names,
    # we'll also store a full_name field which will come from the "fn"
    # property.
    add_column :people, :full_name, :string
    
    add_index :people, :full_name
  end

  def self.down
  end
end
