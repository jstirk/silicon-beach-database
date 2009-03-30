class CreateSearchResults < ActiveRecord::Migration
  def self.up
    create_table :search_results do |t|
      t.integer :saved_query_id
      t.integer :person_id
      t.integer :score

      t.timestamps
    end
    
    add_index :search_results, [:saved_query_id, :person_id]
    add_index :search_results, [:saved_query_id, :score]
    add_index :search_results, [:saved_query_id, :updated_at]
  end

  def self.down
    drop_table :search_results
  end
end
