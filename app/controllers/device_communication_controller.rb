require 'pp'

class DeviceCommunicationController < ApplicationController
  
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
  
  def intitieate_response_object    
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
    
    response_object = intitieate_response_object
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
    
    response_object = intitieate_response_object
    course_times = Course.get_available_tee_times(course_id,time,date)
        
    if course_times
       response_object[:status]     = "success"
       response_object[:statusCode] = 200
       response_object[:response]   = course_times
       response_object[:message]    = "The server successfully made the Course.get_available_tee_times() request"
       render :json => response_object.to_json         
     else
       response_object[:message] = "The server failed to make the Course.get_available_tee_times() request"
       render :json => response_object.to_json         
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
    
    response_object = intitieate_response_object
    reservation = Reservation.book_tee_time(email, course_id, golfers, time, date)
    
    if reservation
      response_object[:status]     = "success"
      response_object[:statusCode] = 200
      response_object[:message]    = "The server successfully made the Reservation.book_tee_time() request"
      render :json => response_object.to_json         
    else
      response_object[:message] = "The server failed to make the Reservation.book_tee_time() request"
      render :json => response_object.to_json         
    end
  end
  
  
  # ===================================================================
  # = httpo://presstee.com/device_communication/process_api_request ===
  # ===================================================================
  
  # INPUT: http://www.presstee.com/device_communication/process_api_request
  # OUTPUT: 
  
  def process_api_request
    course_id      = params[:course_id]
    tee_times_data = params[:date]    
    
    pp tee_times_data
    
    process_data   = Course.process_tee_times_data(course_id,tee_times_data)
  end  
  
  
  def cancel_reservation
  end      
  
end

