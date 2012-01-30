require "net/http"
require "net/https"

class Reservation < ActiveRecord::Base
  
  DEFAULT_CC_NUM   = "4217639662603493"  
  DEFAULT_CC_YEAR  = "15"
  DEFAULT_CC_MONTH = "11"

  Reservation::BOOKING_CANCEL_STATUS_CODE   = 0
  Reservation::BOOKING_SUCCESS_STATUS_CODE  = 1
  
  belongs_to :course
  belongs_to :user

  validates_numericality_of :golfers, :greater_than => 1, :less_than => 5, :message => "Invalid number of golfers"
  
  # Book reservation record, creates a Reservation record, connects to user
  # INPUT:   
  # OUTPUT:   

  def self.book_tee_time(email, course_id, golfers, time, date, total)
    reservation_info = {:course_id=>course_id, :golfers=>golfers, :time=>time, :date=>date, :total=>total}
    
    # Make the API reservation call here
    u = User.find_by_email(email)
    course = Course.find(course_id.to_i)
    
    
    #booking = book_time_via_api(reservation_info,u)
    booking = DeviceCommunicationController::API_MODULE_MAP[course.api].book(reservation_info,course,u)
    
    
    if XmlSimple.xml_in(booking.body).has_key?("confirmation")
      confirmation_code = XmlSimple.xml_in(booking.body)["confirmation"][0]
    else
      return nil
    end    

    if booking
      if u 
        r = Reservation.create(reservation_info)
        r.booking_type = u.device_name
        r.confirmation_code = confirmation_code
        r.user = u
        r.save
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
