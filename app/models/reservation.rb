require "net/http"
require "net/https"
require "date"

class Reservation < ActiveRecord::Base
  
  Reservation::BOOKING_CANCEL_STATUS_CODE   = 0
  Reservation::BOOKING_SUCCESS_STATUS_CODE  = 1
  
  belongs_to :course
  belongs_to :user

  validates_numericality_of :golfers, :greater_than => 1, :less_than => 5, :message => "Invalid number of golfers"
  
  CONFIRMATION_SUBJECT = "Tee Time Confirmation"
  CONFIRMATION_BODY = <<-eos
      This message is to confirm your teetime reservation at <coursename>. 
      
      Customer       : <first> <last> <<email>>
      Tee Time       : <teetime> for <golfers> golfers.
      Confirmation   : <confirm>
      
      For your convenience and security, we do not require credit card information to book via our 
      mobile app.  Therefore, if you do not plan on showing up to your teetime, please be sure to 
      cancel via the link below so we can make your slots available to other customers.  
      
      Cancel         :  http://www.presstee.com/cancel?course_id=<course_id>&confirmation_code=<confirm>
      
      Thanks for your business, and hope to see you soon!
      
    eos
    
  REMINDER_SUBJECT = "Tee Time Reminder"
  REMINDER_BODY = <<-eos
      This is a reminder that you have a tee time reservation for tomorrow.  For your convenience 
      and security, we do not require credit card information to book via our mobile app.  Therefore,
      if you do not plan on showing up to your teetime tomorrow, please be sure to cancel via the 
      link below so we can make your slots available to other customers.  
      
      Tee Time       :  <teetime> for <golfers> golfers.
      Cancel         :  http://www.presstee.com/cancel?course_id=<course_id>&confirmation_code=<confirm>
      
      Thanks again for your business.  
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
  
  def self.mail_sub(data,template)
    body = template
    data.each_pair do |k,v|
      body = body.gsub("<#{k}>",v)
    end
    return body
  end
  

  
  def self.book_tee_time(email, course_id, golfers, time, date, total)
    reservation_info = {:course_id=>course_id, :golfers=>golfers, :time=>time, :date=>date, :total=>total}
    
    user = User.find_by_email(email)
    course = Course.find(course_id.to_i)

    confirmation_code = DeviceCommunicationController::API_MODULE_MAP[course.api].book(reservation_info,course,user)

    if !confirmation_code.nil?
      if user 
        r = Reservation.create(reservation_info)
        r.booking_type = user.device_name
        r.confirmation_code = confirmation_code
        r.user = user
        r.save
        puts "date ----------------------"
        puts date
        
        if date.class() == Date
          day_before_tt = date - 1
          date_date = date
        else
          date_date = Date.parse(date)
          day_before_tt = date_date - 1
          
        end
        
        today = Date.today.strftime("%F")
        now = Time.now.strftime("%R")
        
        subs = {
          "first"      => user.f_name.capitalize,
          "last"       => user.l_name.capitalize,
          "email"      => user.email,
          "confirm"    => confirmation_code,
          "teetime"    => date_date.strftime("%A, %B %e") +" at "+Time.parse(time).strftime("%I:%M %p"),
          "golfers"    => golfers,
          "coursename" => course.name,
          "course_id"  => course.id.to_s
        }
        
        # Schedule Tee Time Reminder
        ServerCommunicationController.schedule_mailing(user,CONFIRMATION_SUBJECT,mail_sub(subs,CONFIRMATION_BODY),today,now)
        if day_before_tt > Date.today
          ServerCommunicationController.schedule_mailing(user,REMINDER_SUBJECT,mail_sub(subs,REMINDER_BODY),day_before_tt,time)
        end
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
