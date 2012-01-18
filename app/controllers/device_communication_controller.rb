require 'pp'
require 'json'
require 'apns'

class DeviceCommunicationController < ApplicationController
  
  skip_before_filter :verify_authenticity_token  
  
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
    
    response_object = intitiate_response_object
    user = User.login(f_name, l_name, email, device_name, os_version, app_version)
    
    if user
      response_object[:status]     = "success"
      response_object[:statusCode] = 200
      response_object[:message]    = "The server successfully created a User record"
      render :json => response_object.to_json
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
    a = Rails.cache.fetch("LatestAvailableTimes_"+course_id) {AvailableTeeTimes.find_by_courseid(course_id)}
    
    if date
       dates = JSON.parse(a.data)
       if dates.has_key?(date)
         response_object[:status]     = "success"
         response_object[:statusCode] = 200
         response_object[:message]    = "The server successfully made the Course.get_available_tee_times() request"
          if time
             if dates[date]["hours"].has_key?(time.split(":")[0].to_i.to_s)
               response_object[:response]   = dates[date]["hours"][time.split(":")[0].to_i.to_s]
               render :json => response_object.to_json
             else
               response_object[:statusCode] = 500
               response_object[:message]    = "Sorry, please choose an hour between 6:00 and 18:00 (24 hour format)"
               render :json => response_object.to_json
             end
             
          else
             response_object[:response]   = dates[date]["day"]
             render :json => response_object.to_json
          end
       else
         response_object[:message]    = "Sorry, please choose a date within the next 7 days.."
         render :json => response_object.to_json
       end
       
    else
       render :json => a.data
    end
    

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
    
    response_object = intitiate_response_object
    reservation = Reservation.book_tee_time(email, course_id, golfers, time, date)
    
    if reservation
      response_object[:status]     = "success"
      response_object[:statusCode] = 200
      response_object[:message]    = "The server successfully made the Reservation.book_tee_time() request"
      response_object[:confirmation_code] = reservation.confirmation_code
      render :json => response_object.to_json         
    else
      response_object[:message] = "The server failed to make the Reservation.book_tee_time() request"
      render :json => response_object.to_json         
    end
  end
  
  
  # ===================================================================
  # = httpo://presstee.com/device_communication/process_api_request ===
  # ===================================================================
  
  # This should be moved into a separate API controller at some point, should not be in device communication controller
  # INPUT: http://www.presstee.com/device_communication/process_api_request
  # OUTPUT: 
  
  def process_api_request
    course_id      = params[:course_id]
    response       = params[:tee_times_data]    
    #pp response
    process_data   = Course.process_tee_times_data(response)    
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
      reservations = Reservation.find_all_by_user_id_and_course_id(user.id.to_s,course_id,:order=>"date DESC,time DESC")
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
      render :json => response_object.to_json
      
    else
      response_object[:message] = "The server failed to make the get_reservations() request"
      render :json => response_object.to_json
    end

    
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
    response_object = intitiate_response_object
    
    r = Reservation.find_by_confirmation_code_and_course_id(confirmation_code,course_id)
    if r
      r.destroy
      response_object[:status]     = "success"
      response_object[:statusCode] = 200
      response_object[:message]    = "The server destroyed a reservation with course_id="+course_id+" and confirmation_code="+confirmation_code
      render :json => response_object.to_json
    else
      response_object[:message] = "The server failed to make the Reservation.cancel_reservation() request"
      render :json => response_object.to_json
    end
    
    
    
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
  
      
  
end

