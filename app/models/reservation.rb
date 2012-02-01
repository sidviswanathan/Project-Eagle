require "net/http"
require "net/https"

class Reservation < ActiveRecord::Base
  
  Reservation::BOOKING_CANCEL_STATUS_CODE   = 0
  Reservation::BOOKING_SUCCESS_STATUS_CODE  = 1
  
  belongs_to :course
  belongs_to :user

  validates_numericality_of :golfers, :greater_than => 1, :less_than => 5, :message => "Invalid number of golfers"
  
  CONFIRMATION_BODY = <<-eos
      Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor 
      incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud 
      exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 
      irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla 
      pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia
      deserunt mollit anim id est laborum.
    eos
    
  REMINDER_BODY = <<-eos
      Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor 
      incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud 
      exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 
      irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla 
      pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia
      deserunt mollit anim id est laborum.
    eos
  
  def self.cancel(confirmation_code,course_id)
    reservation = Reservation.find_by_confirmation_code_and_course_id(confirmation_code,course_id)
    course = Course.find(course_id.to_i)
    if DeviceCommunicationController::API_MODULE_MAP[course.api].cancel(reservation)
      reservation.update_attributes(:status_code => Reservation::BOOKING_CANCEL_STATUS_CODE)
      return true
    else
      return false
    end
  end

  def self.book_tee_time(email, course_id, golfers, time, date, total)
    reservation_info = {:course_id=>course_id, :golfers=>golfers, :time=>time, :date=>date, :total=>total}
    
    u = User.find_by_email(email)
    course = Course.find(course_id.to_i)

    confirmation_code = DeviceCommunicationController::API_MODULE_MAP[course.api].book(reservation_info,course,u)

    if !confirmation_code.nil?
      if u 
        r = Reservation.create(reservation_info)
        r.booking_type = u.device_name
        r.confirmation_code = confirmation_code
        r.user = u
        r.save
        day_before_tt = Date.parse(date) - 1
        ServerCommunicationController.
      else 
        logger.info "Did not find a user record with the email #{email}"
        return nil 
      end
    
      if r.save; return r else return nil end
    else
      logger.info "Did not successfully book reservation via API"
      return nil
    end  
  end 
  
  

end
