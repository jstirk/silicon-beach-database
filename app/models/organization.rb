class Organization < ActiveRecord::Base
  has_many :experiences
  has_many :qualifications
  has_many :employees, :through => :experiences, :source => :person, :uniq => true
  has_many :students, :through => :qualifications, :source => :person, :uniq => true
  
  def educates?
    self.qualifications.size > 0
  end
  
  def employs?
    self.experiences.size > 0
  end
end
