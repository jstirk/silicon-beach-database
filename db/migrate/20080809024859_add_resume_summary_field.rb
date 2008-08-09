class AddResumeSummaryField < ActiveRecord::Migration
  def self.up
    # A hResume has a summary field. Add this now.
    add_column :resumes, :summary, :text
  end

  def self.down
    remove_column :resumes, :summary
  end
end
