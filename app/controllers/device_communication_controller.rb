require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'lib/api/fore.rb'

class DeviceCommunicationController < ApplicationController
  
  skip_before_filter :verify_authenticity_token  
  
  DeviceCommunicationController::API_MODULE_MAP = {
    "fore" => Fore
  }
  
  # These are the clinet API endpoints for all devices communicating witht the Prestee server
  # Below is the expected format for paramters received from all client devices
  
  # ==========================================
  # = DEFINE STANDARD PARAMETER FORMATS ======
  # ==========================================

  # course_id     => '1'                (String)   As defined in the Course model
  # golfers       => '2'                (String)   Range between 2-4
  # time          => '07:14'            (String)   24-hour time format
  # date          => '2011-05-11'       (String)
  # f_name        => 'first_name'       (String)
  # l_name        => 'last_name'        (String)
  # email         => 'name@domain.com'  (String)
  # device_name   => 'iPhone'           (String)
  # os_version    => '5.0'              (String)
  # app_version   => '1.0'              (String)
  # tee_time_data =>  'XML object'      (String)      
  
  # ==========================================
  # = DEFINE STANDARD RESPONSE OBJECT FORMAT =
  # ==========================================

  # render :json => {:status=>'success or failure',
  #                  :statusCode => 2XX,4XX,5XX,
  #                  :message=>'Insert comment here',
  #                  :response=>"insert response object here"
  #                 }
  
  def intitiate_response_object    
    response_object              = Hash.new
    response_object[:status]     = "failure"
    response_object[:statusCode] = 500
    response_object[:response]   = ""
    response_object[:message]    = "The server encountered an unexpected condition which prevented it from fulfilling the request"
    return response_object
  end  
  
  
  # ===================================================================
  # = http://presstee.com/device_communication/login =================
  # ===================================================================

  
  def login 
    email        = params[:email]
    f_name       = params[:f_name]
    l_name       = params[:l_name]
    device_name  = params[:device_name]
    os_version   = params[:os_version]
    app_version  = params[:app_version]
    redirect     = params[:redirect]
    
    response_object = intitiate_response_object
    user = User.login(f_name, l_name, email, device_name, os_version, app_version)
    
    if user
      session[:current_user_id] = user.id
      response_object[:status]     = "success"
      response_object[:statusCode] = 200
      response_object[:message]    = "The server successfully created a User record"
      if !redirect.nil?
        puts user.id
        render :nothing => true
      else
        render :json => response_object.to_json
      end
      
    else
      response_object[:message] = "The server failed to make the User.login() request"
      render :json => response_object.to_json               
    end    
  end  
  
  # ===================================================================
  # = httpo://presstee.com/device_communication/get_available_times ===
  # ===================================================================
  
  # INPUT: http://www.presstee.com/device_communication/get_available_times?course_id=1&date=2011-12-03&time=08:00
  # INPUT: http://localhost:3000/device_communication/get_available_times?course_id=1&date=2011-12-04&time=08:00
  # OUTPUT: {"response":{"06:00":4,"06:45":4,"06:23":4,"06:37":4,"06:15":4,"06:07":4,"06:52":4,"06:30":4},"status":"success","message":"The server successfully made the Course.get_available_tee_times() request","statusCode":200}
  
  def get_available_times
    course_id    = params[:course_id]
    time         = params[:time]    
    date         = params[:date]
    
    response_object = intitiate_response_object
    updated_course = Rails.cache.fetch("Updated_Course_"+course_id) {Course.find(course_id.to_i)}
    
    if updated_course
      if date
         dates = JSON.parse(updated_course.available_times)
         if dates.has_key?(date)
           response_object[:status]     = "success"
           response_object[:statusCode] = 200
           response_object[:message]    = "The server successfully made the Course.get_available_tee_times() request"
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
  
  # ===================================================================
  # = httpo://presstee.com/device_communication/book_reservation ======
  # ===================================================================
  
  # INPUT: http://www.presstee.com/device_communication/book_reservation?email=arguer.11@gmail.com&course_id=1&date=2011-12-03&time=08:00&golfers=4
  # OUTPUT: {"status":"success","message":"The server successfully made the Reservation.book_tee_time() request","response":"","statusCode":200}
  
  def book_reservation
    
    email       = params[:email]
    course_id   = params[:course_id]
    golfers     = params[:golfers]
    time        = params[:time]    
    date        = params[:date]    
    total       = params[:total]
    
    logger.info params
    
    response_object = intitiate_response_object
    
    if Date.parse(date) > (Date.today+8)
      reservation = ServerCommunicationController.schedule_booking(email, course_id, golfers, time, date, total)
      response_object[:status]     = "success"
      response_object[:statusCode] = 200
      response_object[:message]    = "The server successfully made the Reservation.book_tee_time() request"
      response_object[:confirmation_code] = "none"
    else
      reservation = Reservation.book_tee_time(email, course_id, golfers, time, date, total)
      if reservation
        response_object[:status]     = "success"
        response_object[:statusCode] = 200
        response_object[:message]    = "The server successfully made the Reservation.book_tee_time() request"
        response_object[:confirmation_code] = reservation.confirmation_code      
      else
        response_object[:message] = "The server failed to make the Reservation.book_tee_time() request"    
      end
    end
    render :json => response_object.to_json
    
     
  end
  
  
  # ===================================================================
  # = httpo://presstee.com/device_communication/process_api_request ===
  # ===================================================================
  
  # This should be moved into a separate API controller at some point, should not be in device communication controller
  # INPUT: http://www.presstee.com/device_communication/process_api_request
  # OUTPUT: 
  
  def process_api_request
    courses = Course.all
    courses.each do |course|
      DeviceCommunicationController::API_MODULE_MAP[course.api].update(course)
    end
    render :nothing => true
  end  
  
  
  # ===================================================================
  # = http://presstee.com/device_communication/get_reservations ===
  # ===================================================================
  
  # This should be moved into a separate API controller at some point, should not be in device communication controller
  # INPUT: http://www.presstee.com/device_communication/cancel_reservation
  # OUTPUT:
  
  
  def get_reservations
    course_id           = params[:course_id]
    email               = params[:email]
    response_object = intitiate_response_object
    
    user = User.find_by_email(email)
    
    if user
      reservations = Reservation.find_all_by_user_id_and_course_id_and_status_code(user.id.to_s,course_id,Reservation::BOOKING_SUCCESS_STATUS_CODE,:order=>"date DESC,time DESC")
      response_object[:status]     = "success"
      response_object[:statusCode] = 200
      response_object[:message]    = "The server succesfully made the get_reservations() request"
      reservation_list = reservations.to_json
      r_list = []
      JSON.parse(reservation_list).each do |r|
        logger.info r['reservation']
        r_list.push(r['reservation'])
      end
      response_object[:data]       = r_list
    else
      response_object[:message] = "The server failed to make the get_reservations() request (Login Failure)"
    end
    render :json => response_object.to_json
  end
  
  
  # ===================================================================
  # = httpo://presstee.com/device_communication/cancel_reservation ===
  # ===================================================================
  
  # This should be moved into a separate API controller at some point, should not be in device communication controller
  # INPUT: http://www.presstee.com/device_communication/cancel_reservation
  # OUTPUT:
  
  
  def cancel_reservation
    course_id           = params[:course_id]
    confirmation_code   = params[:confirmation_code]
    response_object     = intitiate_response_object
    
    cancelled = Reservation.cancel(confirmation_code,course_id)
    
    if cancelled
      response_object[:status]     = "success"
      response_object[:statusCode] = 200
      response_object[:message]    = "The server destroyed a reservation with course_id="+course_id+" and confirmation_code="+confirmation_code
    else
      response_object[:message] = "The server failed to make the Reservation.cancel_reservation() request, cannot find reservation object"
    end
    render :json => response_object.to_json
  end  
  
  # ===================================================================
  # = httpo://presstee.com/device_communication/push_deal ===
  # ===================================================================
  
  # This should be moved into a separate API controller at some point, should not be in device communication controller
  # INPUT: http://www.presstee.com/device_communication/push_deal
  # OUTPUT:
  
  def push_deal
    APNS.pem = '/app/config/apns.pem'
    APNS.send_notification(params[:token],params[:message])
  end
  
  
  # ===================================================================
  # = httpo://presstee.com/device_communication/test_mail ===
  # ===================================================================
  
  # This should be moved into a separate API controller at some point, should not be in device communication controller
  # INPUT: http://www.presstee.com/device_communication/push_deal
  # OUTPUT:
  
  def test_mail
    
    query = "/blah"
    
    url = URI.parse("http://dump-them.appspot.com")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = false
    headers = {}
    puts "hello schedule_mailing"
    response = http.get(query, headers)

    render :nothing => true
  end
  
  
  
end

