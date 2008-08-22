class Experience < ActiveRecord::Base
  belongs_to :person
  belongs_to :organization
  
  # Include in the common code to parse the hCalendar models
  include Hcalendar
end
