class SearchResult < ActiveRecord::Base
	belongs_to :person
	belongs_to :saved_query
end
