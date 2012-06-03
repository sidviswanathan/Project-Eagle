require "net/http"
require "net/https"
require "date"
require 'chronic'
require 'time'
require 'pp'

class Reservation < ActiveRecord::Base
  
  Reservation::BOOKING_CANCEL_STATUS_CODE   = 0
  Reservation::BOOKING_SUCCESS_STATUS_CODE  = 1
  
  belongs_to :course
  belongs_to :customer

  validates_numericality_of :golfers, :greater_than => 1, :less_than => 5, :message => "Invalid number of golfers"
  
  #validates_uniqueness_of :customer_id, :scope => :date
  
  CONFIRMATION_SUBJECT = "Tee Time Confirmation"
  CONFIRMATION_BODY = <<-eos
      This message is to confirm your teetime reservation at <coursename>. 
      
      Customer       : <first> <last> <<email>>
      Tee Time       : <teetime> for <golfers> golfers.
      Confirmation   : <confirm>
      
      For your convenience and security, we do not require credit card information to book via our mobile app.  Therefore, if you do not plan on showing up to your teetime, please be sure to cancel via the link below so we can make your slots available to other customers.  
      
      Cancel         :  http://www.presstee.com/cancel?course_id=<course_id>&confirmation_code=<confirm>
      
      Thanks for your business, and hope to see you soon!
      
    eos
  
  CONFIRMATION_SMS = "Deep Cliff Booking (<confirm>) <golfers> golfers on <teetime>.  Reply with '1' to cancel"
  CONFIRMATION_VOICE = "This is Deep Cliff Golf Course calling about your Tee Time Reservation for <golfers> Golfers on <teetime>.  Your confirmation code is <confirm>.  I repeat, <confirm>.  If you would like to cancel this reservation, please press 9 now.  If you would like to talk with a course staff member, please press 0 now.  Thanks again for your business and have a wonderful day!"
    
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
    
  
  REMINDER_SMS = "Tee Time Reminder: For <golfers> Golfers on <teetime>.  Reply with '1' to cancel ."
  REMINDER_VOICE = "This is Deep Cliff Golf Course reminding you about your Tee Time Reservation for <golfers> Golfers on <teetime>.  Your confirmation code is <confirm>.  I repeat, <confirm>.  If you would like to cancel this reservation, please press 9 now.  If you would like to talk with a course staff member, please press 3 now.  Thanks again for your business and have a wonderful day!"
  
  
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
      if v.nil?
        v = ""
      end
      body = body.gsub("<#{k}>",v)
    end
    return body
  end
  
  def send_confirmations(user,reservation)
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
    ServerCommunicationController.schedule_contact(user,CONFIRMATION_SUBJECT,mail_sub(subs,CONFIRMATION_BODY),today,now,mail_sub(subs,CONFIRMATION_SMS),mail_sub(subs,CONFIRMATION_VOICE),true)
    if day_before_tt > Date.today
      ServerCommunicationController.schedule_contact(user,REMINDER_SUBJECT,mail_sub(subs,REMINDER_BODY),day_before_tt,time,mail_sub(subs,REMINDER_SMS),mail_sub(subs,REMINDER_VOICE),false)
    end
  end

  # This method is called from DeviceCommunication Controller which is called by the clients (mobile web, SMS< etc.)
  # Validates users, creates a reservation record in db, links it with Customer (Customer is the end-user)
  # If successfully created Reservation record, makes the book tee time call to the API for the course            
  def self.book_tee_time(user, course_id, golfers, time, date, total)
    reservation_info = {:course_id=>course_id, :golfers=>golfers, :time=>time, :date=>date, :total=>total}
    puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    pp reservation_info
    puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    puts user.class
    puts user
    puts "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    course = Course.find(course_id.to_i)
    if user
      puts "got into the if user block"
      r = Reservation.new(reservation_info)
      user_data = JSON.parse(user.data)
      r.booking_type = user_data[:device_name]
      r.customer = user

      if r.valid?
        confirmation_code = DeviceCommunicationController::API_MODULE_MAP[course.api].book(reservation_info,course,user)                      #Makes the booking call to the API for the golf course        
        puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
        puts confirmation_code
        puts "&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&"
        if !confirmation_code.nil?                                                                                                            # Returns confirmation code if booked successfully, else returns the entire response
          r.confirmation_code = confirmation_code
          r.save
          puts "Just saved the reservation record"
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
          ServerCommunicationController.schedule_contact(user,CONFIRMATION_SUBJECT,mail_sub(subs,CONFIRMATION_BODY),today,now,mail_sub(subs,CONFIRMATION_SMS),mail_sub(subs,CONFIRMATION_VOICE),true)
          if day_before_tt > Date.today
            ServerCommunicationController.schedule_contact(user,REMINDER_SUBJECT,mail_sub(subs,REMINDER_BODY),day_before_tt,time,mail_sub(subs,REMINDER_SMS),mail_sub(subs,REMINDER_VOICE),false)
          end
          return r,true,"Congrats, you succesfully booked a tee time at Deep Cliff!"

        else
          # There API call failed for some reasons
          logger.info "----- #{Time.now} ----- BOOKING FAILURE | #{user.name} | #{course_id.to_s} | #{golfers.to_s} | #{time.to_s} | #{date.to_s} | #{total.to_s}"                               # This is the exact message that is sent back tot he cleint when a tee time is booked
          #In the future, Give user the exact reason why the booking failed
          Mailer.deliver_api_booking_error(PP.pp(confirmation_code, ""))
          return nil,false,"We were unable to book this tee time. PLease try again later or call Deep Cliff Golf Course at (408)-253-5357."          
        end
        
      else
        logger.info "Only one reservation per date per user is allowed.  Please select a different date and try again!"
        return nil,false,"We're sorry, only one reservation per day is allowed. Please choose another day and time and try again!"
      end
      
    else
      logger.info "Did not find a user record with the email #{email}"
      return nil,false,"Did not find a user record with the email #{email}"
    end   
  end 
  
  

end
