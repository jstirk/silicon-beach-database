# NOTE: This is a very quick and dirty search implementation which uses keywords
#       and allows for queries to be refined by a Bayesian-esque method of
#       penalizing keywords in content voted down, but rewarding keywords in
#       content voted up.

class SavedQuery < ActiveRecord::Base
	has_many :search_results, :dependent => :destroy
	has_many :search_weights, :dependent => :destroy

	after_save :update_results
	
	# 
	def update_results(limit=10)
		# Work out our core searc terms
		terms={}
		SavedQuery.split_keywords(self.query).each do |term|
			terms[term]=1
		end
		
		weighting=terms.clone
		# Now, if we've previously done the search, and created SearchWeight rows,
		# start to factor them in now.
		cnt=SearchWeight.count(:conditions => { :saved_query_id => self.id })
		per_kwd_weight=1.0 / cnt
		SearchWeight.find_all_by_saved_query_id(self.id).each do |sw|
			# We don't give these words a full weighting to allow our search terms to
			# really shine through.
			# TODO: Should 0.5 here be the fair proportion given the number of other
			#       SearchWeights?
			weighting[sw.keyword] ||= 0
			weighting[sw.keyword] += (sw.value.to_f * per_kwd_weight) if terms[sw.keyword].blank?
		end
		
		# Prepare our scores
		scores={}
		
		# Prepare our SQL snippets
		rconditions=[[]]
		exconditions=[[]]
		edconditions=[[]]
		terms.each do |t, score|
			tx="%#{t}%"
			rconditions[0] << 'summary LIKE ?'
			rconditions << tx
			exconditions[0] << '(title LIKE ? OR summary LIKE ?)'
			exconditions << tx
			exconditions << tx
			edconditions[0] << '(degree LIKE ? OR summary LIKE ?)'
			edconditions << tx
			edconditions << tx
		end
		rconditions[0]=rconditions[0].join(' AND ')
		exconditions[0]=exconditions[0].join(' AND ')
		edconditions[0]=edconditions[0].join(' AND ')
		
		# Look in Resume summaries
		rs=Resume.find(:all, :select => 'person_id,summary', :conditions => rconditions)
		rs.each do |r| 
			scores[r.person_id] ||= 0
			# Count the number of times each of our search terms appears in the summary
			# KLUDGE: There has to be a better way of counting no. of instances within
			#         a string.
			weighting.each do |t, adj|
				scores[r.person_id] += ((r.summary.split(Regexp.new(t,'i')).size - 1) * adj)
			end
		end
		
		# Look in Experience titles and summaries
		exs=Experience.find(:all, :select => 'person_id, title, summary', :conditions => exconditions)
		exs.each do |ex| 
			scores[ex.person_id] ||= 0
			# Count the number of times each of our search terms appears in the title
			# and the summary
			# KLUDGE: There has to be a better way of counting no. of instances within
			#         a string.
			weighting.each do |t, adj|
				scores[ex.person_id] += ((ex.title.split(Regexp.new(t,'i')).size - 1) * adj)
				scores[ex.person_id] += ((ex.summary.split(Regexp.new(t,'i')).size - 1) * adj)
			end
		end
		
		# Look in Qualification degrees and summaries
		eds=Qualification.find(:all, :select => 'person_id, degree, summary', :conditions => edconditions)
		eds.each do |ed|
			scores[ed.person_id] ||= 0
			# Count the number of times each of our search terms appears in the degree
			# and the summary
			# KLUDGE: There has to be a better way of counting no. of instances within
			#         a string.
			weighting.each do |t, adj|
				scores[ed.person_id] += ((ed.degree.split(Regexp.new(t,'i')).size - 1) * adj)
				scores[ed.person_id] += ((ed.summary.split(Regexp.new(t,'i')).size - 1) * adj)
			end
		end
		
		# Update the Results
		uat=Time.now.utc
		scores.each do |pid, score|
			r=SearchResult.find_or_create_by_saved_query_id_and_person_id(self.id, pid)
			r.score=score
			r.updated_at=uat
			r.save
		end
		
		# Find any SearchResults we didn't update
		SearchResult.delete_all("saved_query_id = #{self.id} AND updated_at < '#{uat.to_s(:db)}'")
		
		return scores
	end
	
	def vote(person, value)
		# Get all the details for this person and build up our keywords
		p=Person.find(person)
		keywords=SavedQuery.split_keywords(p.resume.summary)
		p.experiences.each do |ex|
			keywords=keywords + SavedQuery.split_keywords(ex.summary)
			keywords=keywords + SavedQuery.split_keywords(ex.title)
		end
		p.qualifications.each do |ed|
			keywords=keywords + SavedQuery.split_keywords(ed.summary)
			keywords=keywords + SavedQuery.split_keywords(ed.degree)
		end
		# Take all of our keywords, and created SearchWeight rows for each one
		keywords.uniq!
		cad=Time.now.utc
		keywords.each do |kwd|
			sw=SearchWeight.find_or_create_by_saved_query_id_and_keyword_and_person_id(self.id, kwd, p.id)
			sw.created_at=cad
			sw.value=value
			sw.save
		end
		SearchWeight.delete_all("saved_query_id = #{self.id} AND person_id = #{p.id} AND created_at < '#{cad.to_s(:db)}'")
	end
	
	def self.split_keywords(query)
		# Convert spacer punctuation
		query=query.downcase
		query.gsub!(/[,:;\.\-\?\+\*"'\(\)]/,' ')
		
		# Remove junk words
		junk=%w{ the and this that it's a of from eg ie use has been example to its their my our his her on in it }
		junk.each do |word|
			query.gsub!(Regexp.new("\\b#{word}\\b",'i'),'')
		end
		query.gsub!(/\s+/,' ')
		query.split(' ')
	end
end
