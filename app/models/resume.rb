class Resume < ActiveRecord::Base

  belongs_to :person
  
  # TODO: before_create parse the URI and check it's sane
  
  # Find all of the Resumes that need to be updated, and update them now.
  def self.update_all!
    # Because it's feasible that we could get a huge list here, only fetch
    # the IDs initially. Then, we'll request each resume individually so
    # as that if another process is running at the same time, we won't
    # re-do the same work.
    conditions=[ 'update_again_at <= ? OR update_again_at IS NULL', Time.now ]
    Resume.find(:all, :conditions => conditions,
                :select => :id ).each do |rid|
      # Another process may have come through before us, which is why we
      # check update_again_at now.
      r=Resume.find(rid.id, 
                    :conditions => conditions,
                    :lock => true)
      r.update! if r
    end
    true
  end

  # Update this Resume now
  def update!
    response=SBA::request(self.uri, :last_modified => self.last_updated_at)
    # NOTE: We don't care if we've been forced to follow redirects - we
    #       continue to get the URL requested. This allows authors to
    #       delegate their resumes to other providers via redirects but
    #       still allow them to change it in the future. If we updated our
    #       database when we followed a redirect, we run the risk of failing
    #       to catch if they change the destination in their registered page
    #       forcing the redirection.
    
    # TODO: Handle any exceptions it might raise - in particular marking the
    # feed as bad so as that we don't check it for a while, and eventually
    # stop checking it entirely if there continue to be errors.
    begin
      case response[:status]
        when 200
          # Update this record
          self.parse_content!(response[:content])
        when 304
          # It's the same content as last time - so we still update the 
          # time that we next check it.
        else
          # An unknown response type.
          raise "Unknown HTTP Status: #{response[:status]}"
      end
    rescue
      logger.error "Error: Updating Resume #{self.id}\n  #{$!}"
      pp $!.backtrace
    end
    
    # Always update the time - even if it's an error
    self.calculate_next_update!
    
    true
  end

  # Parse the (X)HTML content and update this resume's data.
  def parse_content!(content)
    # Roll the transaction back to destroy any new models if we hit any
    # problems.
    Resume.transaction do
      h=Hpricot(content)
      hresume=h/".hresume"
      
      # Obviously if it's not a hResume document, we don't want
      # to continue.
      raise 'Not a hResume document' if hresume.blank?
    
      # Data we're going to write to our model
      data={}
      
      # TODO: KLUDGE! Doing this because the vcalendar .experience elements
      #       include the .summary element. Ideally we only want the main
      #       summary, not summaries of every job. This kludge makes LinkedIn
      #       content sane only.
      #       We need to filter out the other .summary elements.
      summary=(hresume/".summary").first.inner_text.strip
      
      contact=(hresume/".contact")/'.vcard'
      if self.person.nil? then
        self.person=Person.new
      end
      
      # Not having a contact vCard to let us know who they are is
      # a big fail. We don't want to list them in that case.
      raise 'Missing ontact vCard' if contact.blank?
      
      # Let the Person model parse the vcard information.
      self.person.parse_content!(contact)
      
      # Parse the major bits out of the hResume format
      parse_skills(hresume)
      parse_experiences(hresume)      
      parse_educations(hresume)
      
      data[:summary]=summary
      data[:last_content]=content
      
      self.update_attributes!(data)
    end
  end
    
  # Updates the Resume's update_again_at field, specifying when we should
  # next automatically fetch this page.
  def calculate_next_update!
    # Work out when next to poll.
    # TODO: Allow author to provide TTL data in the content.
    self.update_attribute(:update_again_at, Time.now + 1.week)
  end
  
private
  # Parses the hResume .skill and .skills elements
  def parse_skills(hresume)
    skills=[]
    (hresume/".skill").each do |el|
      skills << el.inner_text.strip
    end
    (hresume/".skills").each do |el|
      el.inner_text.strip.split(/\r\n|\r|\n|,/).each do |t|
        skills << t.strip
      end
    end
    
    skills.each do |s|
      skill=self.person.skills.find_or_create_by_value(s)
      skill.save!
    end
  end

  # Parses the hResume .experience elements
  def parse_experiences(hresume)
    (hresume/".experience").each do |el|
      exp=Experience.new(:person => self.person)
      exp.parse_content!(el)
      exp.save_or_replace_existing!
    end
    
    # TODO: Clean out Experiences that are no longer referenced in Resumes
  end
  
  # Parses the hResume .education elements
  def parse_educations(hresume)
    (hresume/".education").each do |el|
      qual=Qualification.new(:person => self.person)
      qual.parse_content!(el)
      qual.save_or_replace_existing!
    end
    
    # TODO: Clean out Qualifications that are no longer referenced in Resumes
  end
  
end
