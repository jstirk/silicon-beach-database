module Hcalendar
  # TODO: before_save update the duration field
  
  HCALENDAR_DATE_FORMAT='%Y-%m-%d'
  
  # Map the hCalendar fields to the fields we handle.
  # Keys are hCalendar classes, values are fields on Experience
  # TODO: Add photo, etc.
  HCALENDAR_MAPPING={
      '.org' => 'organization_name',
      '.dtstart' => 'dtstart',
      '.dtend' => 'dtend',
      '.duration' => 'formatted_duration',
      '.title' => 'title',
      '.degree' => 'degree',
      '.summary' => 'summary',
      '.description' => 'summary'
  }
  
  # Parses the (X)HTML hCalendar content for this model
  # Handles either a Hpricot object, or a String.
  def parse_content!(content)
    if content.is_a?(String) then
      content=Hpricot(content)
    end
    
    HCALENDAR_MAPPING.each do |search, field|
      element=content/search
      logger.warning "Found multiple (#{element.length}) elements for \"#{search}\"" if element.length > 1
      element=element.first
      
      # Handle abbr-design-pattern
      # (http://microfotrmats.org/wiki/abbr-design-pattern)
      # If the element is an ABBR, the title should be machine readable format.
      value=nil
      if !element.blank? then
        if element.name.downcase == 'abbr' then
          value=element['title'].strip
        else
          value=element.inner_text.strip
        end
        # Set the field, but only if this class responds to it
        # NOTE: This allows us to handle, eg: an Experience that has a 
        #       .degree element, but doesn't actually need it. We'll skip it.
        self.send(field + '=', value) if self.respond_to?(field + '=')
      end
    end
  end
  
  # Looks through all of the existing rows that look like the
  # one provided (for the same Person) and decides whether this row should be
  # saved (no duplicates exist) or it should be merged into an existing row.
  def save_or_replace_existing!
    # See if a model exists that looks similar to this.
    # We match based upon the organization and start date, as it seems safer
    # than matching any other way. Matching on title (for example) could break
    # if someone takes the same job a second time.
    match=self.class.find_by_person_id_and_organization_id_and_started_at(
                self.person_id,
                self.organization_id,
                self.started_at)

    # By default we're going to save this row
    model=self
       
    if match then
      # Copy our fields across to the existing model
      %w( started_at ended_at ).each do |field|
        match.send("#{field}=", model.send(field))
      end
      model=match
    end
    # else, there's no duplicate, so just save this one
    model.save!
  end
  
  # Provide a wrapper to create or find the relevant Organization
  # by name.
  def organization_name()
    self.organization.name unless self.organization.nil?
  end
  def organization_name=(name)
    # NOTE: Because LinkedIn has a habit of adding "\n\s+(Self-Employed)" we
    #       will strip this out. It looks messy, and will wreck out data a
    #       little.
    name.gsub!(/\n\s+\(Self-employed\)/i,'')
    
    self.organization=Organization.find_or_create_by_name(name)
  end
  
  # Provide wrappers to access started_at, ended_at, etc. using the formats
  # that hCalendar works with.
  def dtstart
    self.started_at.strftime(HCALENDAR_DATE_FORMAT) unless self.started_at.nil?
  end
  def dtstart=(date)
    self.started_at=correct_partial_date(date, :start) unless date.blank?
  end
  def dtend
    self.ended_at.strftime(HCALENDAR_DATE_FORMAT) unless self.ended_at.nil?
  end
  def dtend=(date)
    self.ended_at=correct_partial_date(date, :end) unless date.blank?
  end
  def formatted_duration()
    years=(self.duration / 1.year).floor
    months=((self.duration % 1.year) / 1.month).floor
    o=[ 'P' ]
    o << "#{years}Y" unless years < 1
    o << "#{months}M" unless months < 1
    o.join('')
  end
  def formatted_duration=(duration)
    match=duration.match(/P(\d+Y)?(\dM)?/)
    seconds=(match[1].to_i * 1.year) + (match[2].to_i * 1.month)
    self.duration=seconds
  end
    
private
  # The hEvent format seems to allow partial dates like "2008".
  # This corrects that and uses Time.utc to return a Time object.
  # NOTE: We always parse these dates as UTC so as that we don't have any
  #       date skew when they get converted from local TZ.
  # at can be either :start or :end to signify at the beginning or
  #    end of the relevant period.
  def correct_partial_date(date, at=:start)
    raise ArgumentErrror, 'at must be :start or :end of period' if ![:start, :end].include?(at)

    match=date.match(/(\d{4})?(-(\d{1,2})(-(\d{1,2}))?)?/)
    year=match[1]
    month=match[3]
    day=match[5]
    if at == :start then
      month='01' if month.blank?
      day='01' if day.blank?
    else
      # at == :end
      month='12' if month.blank?
      day=Time::COMMON_YEAR_DAYS_IN_MONTH[month.to_i] if day.blank?
    end
    Time.utc(year, month, day)
  end
end
