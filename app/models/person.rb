class Person < ActiveRecord::Base
  has_many :resumes, :dependent => :destroy
  has_many :urls, :dependent => :destroy
  has_many :skills, :dependent => :destroy
  has_many :experiences, :dependent => :destroy
  has_many :qualifications, :dependent => :destroy
  
  has_one :current_employment, :class_name => 'Experience', :order => 'started_at DESC'
  
  # TODO: Consider 1-to-many later
  has_one :resume
  
  # Map the vCard fields to the fields we handle.
  # Keys are vCard classes, values are fields on Person
  # TODO: Add photo, etc.
  VCARD_MAPPING={
      '.given-name' => 'given_name',
      '.family-name' => 'family_name',
      '.fn' => 'full_name',
      '.title' => 'title',
      '.adr .street-address' => 'street_address',
      '.adr .locality' => 'locality',
      '.adr .region' => 'region',
      '.adr .postal-code' => 'postal_code',
      '.adr .country' => 'country',
      '.geo' => 'condensed_geo',
      '.geo .latitude' => 'latitude',
      '.geo .longitude' => 'longitude'
  }
  
  # Parses the (X)HTML vCard content for this Person.
  # Handles either a Hpricot object, or a String
  def parse_content!(content)
    if content.is_a?(String) then
      content=Hpricot(content)
    end
    
    VCARD_MAPPING.each do |search, field|
      element=content/search
      logger.warning "Found multiple (#{element.length}) elements for \"#{search}\"" if element.length > 1
      element=element.first
      
      # Handle abbr-design-pattern
      # (http://microfotrmats.org/wiki/abbr-design-pattern)
      # If the element is an ABBR, the title should be machine readable format.
      value=nil
      if !element.blank? then
        if element.name.downcase == 'abbr' then
          value=element['title']
        else
          value=element.inner_text.strip
        end
        self.send(field + '=', value)
      end
    end
    
    # Handle .url elements
    (content/"a.url").each do |a|
      url=self.urls.find_or_create_by_url(a[:href])
      url.description=a.inner_text.strip
      url.save!
    end
    
    # Be sure to raise exceptions on errors so as that we can roll
    # back changes if we need to.
    self.save!
  end
  
  # Some other microformats.org pages suggest that a valid geo definition
  # is also "lat;long"
  # These two methods handle that format for reading and writing.
  def condensed_geo()
    "#{self.latitude};#{self.longitude}" unless self.latitude.nil? or self.longitude.nil?
  end
  
  def condensed_geo=(geo)
    match=geo.match(/([\d\.]+);([\d\.]+)/)
    if match then
      self.latitude=match[1]
      self.longitude=match[2]
      true
    end
  end

end
