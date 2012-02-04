class Course < ActiveRecord::Base  
  has_many :users
  has_many :reservations
  
  def self.get_available_times(course,dater)  
    dates = JSON.parse(course.available_times)
    return dates[dater]["day"]
  end

  
end
