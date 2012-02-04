class Course < ActiveRecord::Base  
  has_many :users
  has_many :reservations
  
  def self.get_available_times(params)
    self.id
    
    course_id    = params[:course_id]
    time         = params[:time]    
    date         = params[:date]
    
    response_object = intitiate_response_object
    updated_course = Rails.cache.fetch("Updated_Course_"+course_id) {Course.find(course_id.to_i)}
    
    if updated_course
      if date
         dates = JSON.parse(updated_course.available_times)
         if dates.has_key?(date)

            if time
               if dates[date]["hours"].has_key?(time.split(":")[0].to_i.to_s)
                 response_object[:response]   = dates[date]["hours"][time.split(":")[0].to_i.to_s]
               else
                 response_object[:statusCode] = 500
                 response_object[:message]    = "Sorry, please choose an hour between 6:00 and 18:00 (24 hour format)"
               end
            else
               response_object[:response]   = dates[date]["day"]
            end
         else
           response_object[:message]    = "Sorry, please choose a date within the next 7 days.."
         end
      elsif !updated_course.available_times.nil?
        response_object[:status]     = "success"
        response_object[:statusCode] = 200
        response_object[:message]    = "The server successfully made the Course.get_available_tee_times() request"
        response_object[:response]   = updated_course.available_times
      else
        response_object[:message]    = "The server does not have data for the Course with ID:#{course_id}"
      end
    else
      response_object[:message]    = "The server could not find a Course with ID:#{course_id}"
    end
    render :json => response_object.to_json
  end
  
end
