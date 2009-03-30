class SearchWeight < ActiveRecord::Base
	belongs_to :saved_query
	belongs_to :person
end
