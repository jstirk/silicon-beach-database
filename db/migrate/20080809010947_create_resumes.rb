class CreateResumes < ActiveRecord::Migration
  def self.up
    create_table :resumes do |t|
      # The URI of the resume resource we're checking
      t.string :uri
      
      # Time we last fetched the resource to report freshness, and
      # to facilitate If-Modified-Since
      t.datetime :last_updated_at
      
      # Specify when we should fetch the feed again independently of the last
      # check time. This allows authors to specify a TTL.
      t.datetime :update_again_at
      
      # Keep a copy of the last content we fetched so as that we can re-parse it
      # without having the hit the network again in case of a parsing bug.
      t.text :last_content

      t.timestamps
    end
    
    # Only allow each unique URI to be fetched once. We will need to do
    # additional checks, as minor URI variations can still request the same
    # document. eg: "http://example.com/resume" vs. 
    #               "http://www.example.com/resume" vs.
    #               "http://example.com/resume?"
    add_index :resumes, :uri, :unique => true
  end

  def self.down
    drop_table :resumes
  end
end
