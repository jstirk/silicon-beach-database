class CreateSearchWeights < ActiveRecord::Migration
  def self.up
    create_table :search_weights do |t|
      t.integer :saved_query_id
      t.integer :person_id
      t.string :keyword
      t.integer :value

      t.timestamps
    end
    
    add_index :search_weights, :saved_query_id
    add_index :search_weights, :person_id
    add_index :search_weights, [ :saved_query_id, :keyword ]
  end

  def self.down
    drop_table :search_weights
  end
end
