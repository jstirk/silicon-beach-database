class CreateSavedQueries < ActiveRecord::Migration
  def self.up
    create_table :saved_queries do |t|
      t.string :query

      t.timestamps
    end
  end

  def self.down
    drop_table :saved_queries
  end
end
