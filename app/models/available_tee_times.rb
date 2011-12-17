class AvailableTeeTimes < ActiveRecord::Base
  validates_presence_of :courseid
  validates_uniqueness_of :courseid
end
