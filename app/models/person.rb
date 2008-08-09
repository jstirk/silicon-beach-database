class Person < ActiveRecord::Base
  has_many :resumes, :dependent => :destroy
  has_many :urls, :dependent => :destroy
  has_many :skills, :dependent => :destroy
  
  # Map the vCard fields to the fields we handle.
  # Keys are vCard classes, values are fields on Person
  # TODO: Add geo, photo, etc.
  VCARD_MAPPING={
      '.given-name' => 'given_name',
      '.family-name' => 'family_name',
      '.fn' => 'full_name',
      '.title' => 'title',
      '.adr .street-address' => 'street_address',
      '.adr .locality' => 'locality',
      '.adr .region' => 'region',
      '.adr .postal-code' => 'postal_code',
      '.adr .country' => 'country'  
  }
  
  # Parses the (X)HTML vCard content for this Person.
  # Handles either a Hpricot object, or a String
  def parse_content!(content)
    if content.is_a?(String) then
      content=Hpricot(content)
    end
    
    VCARD_MAPPING.each do |search, field|
      elements=content/search
      self.send(field + '=', elements.inner_text.strip)
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
end
