class Organization < ActiveRecord::Base
  has_many :experiences
  has_many :qualifications
  has_many :employees, :through => :experiences, :source => :person, :uniq => true
  has_many :students, :through => :qualifications, :source => :person, :uniq => true
end
