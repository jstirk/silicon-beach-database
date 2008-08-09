class AddResumePersonId < ActiveRecord::Migration
  def self.up
    # A Resume belongs to a single Person
    add_column :resumes, :person_id, :integer
    
    add_index :resumes, :person_id
  end

  def self.down
    remove_column :resumes, :person_id
  end
end
