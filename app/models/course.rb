class Course < ActiveRecord::Base  
  has_many :users
  has_many :reservations
  
  def self.get_available_times(course)    
    
    if !course.available_times.nil?
      dates = JSON.parse(course.available_times)
      return dates[date]["day"]
    else
      return []
    end
  end

  
end
