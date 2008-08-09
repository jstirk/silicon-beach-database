class Resume < ActiveRecord::Base

  belongs_to :person
  
  # TODO: before_create parse the URI and check it's sane

  def update!
    response=SBA::request(self.uri, :last_modified => self.last_updated_at) 
    # TODO: Handle any exceptions it might raise - in particular marking the
    #       feed as bad so as that we don't check it for a while, and eventually
    #       stop checking it entirely if there continue to be errors.
    
    # NOTE: We don't care if we've been forced to follow redirects - we
    #       continue to get the URL requested. This allows authors to
    #       delegate their resumes to other providers via redirects but
    #       still allow them to change it in the future. If we updated our
    #       database when we followed a redirect, we run the risk of failing
    #       to catch if they change the destination in their registered page
    #       forcing the redirection.
    
    case response[:status]
      when 200
        # Update this record
        self.parse_content!(response[:content])
      when 304
        # It's the same content as last time - so we still update the 
        # time that we next check it.
        self.calculate_next_update!
      else
        # TODO: An unknown response type.
    end
  end

  # Parse the (X)HTML content and update this resume's data.
  def parse_content!(content)
    # Roll the transaction back to destroy any new models if we hit any
    # problems.
    Resume.transaction do
      h=Hpricot(content)
      hresume=h/".hresume"
    
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
      # Let the Person model parse the vcard information.
      self.person.parse_content!(contact)
      
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
  
end
