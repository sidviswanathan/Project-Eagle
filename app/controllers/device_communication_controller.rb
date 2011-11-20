class DeviceCommunicationController < ApplicationController
  
  # These are the clinet API endpoints for all devices communicating witht the Prestee server
  # Below is the expected format for paramters received from all client devices
  
  # ==========================================
  # = DEFINE STANDARD PARAMETER FORMATS ======
  # ==========================================

  # course_id    => 1                  (Integer)   As defined in the Course model
  # golfers      => 2                  (Integer    Range between 2-4
  # time         => '07:14'            (String)    24-hour time format
  # date         => '06-05-11'         (String)
  # f_name       => 'first_name'       (String)
  # l_name       => 'last_name'        (String)
  # email        => 'name@domain.com'  (String)
  # device_name  => 'iPhone'           (String)
  # os_version   => '5.0'              (String)
  # app_version  => '1.0'              (String)
  
  # ==========================================
  # = DEFINE STANDARD RESPONSE OBJECT FORMAT =
  # ==========================================

  # render :json => {:status=>'success or failure',
  #                  :statusCode => 2XX,4XX,5XX,
  #                  :message=>'Insert comment here',
  #                  :response=>"insert response object here"
  #                 }
  
  RESPONSE_OBJECT              = {}
  RESPONSE_OBJECT[:status]     = "failure"
  RESPONSE_OBJECT[:statusCode] = 500
  RESPONSE_OBJECT[:response]   = ""
  RESPONSE_OBJECT[:message]    = "The server encountered an unexpected condition which prevented it from fulfilling the request"
  
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
    
    user = User.login(f_name, l_name, email, device_name, os_version, app_version)
    
    if user
      
      RESPONSE_OBJECT[:status]     = "success"
      RESPONSE_OBJECT[:statusCode] = 200
      RESPONSE_OBJECT[:message]    = "The server successfully made the Reservation.book_tee_time() request"
      render :json => RESPONSE_OBJECT.to_json
      
      # reservation = Reservation.book_tee_time(user, course_id, num_golfers, time, date)
      # if reservation
      #   RESPONSE_OBJECT[:status]     = "success"
      #   RESPONSE_OBJECT[:statusCode] = 200
      #   RESPONSE_OBJECT[:message]    = "The server successfully made the Reservation.book_tee_time() request"
      #   render :json => RESPONSE_OBJECT.to_json         
      # else
      #   RESPONSE_OBJECT[:message] = "The server failed to make the Reservation.book_tee_time() request"
      #   render :json => RESPONSE_OBJECT.to_json         
      # end  
    else
      RESPONSE_OBJECT[:message] = "The server failed to make the User.login() request"
      render :json => RESPONSE_OBJECT.to_json               
    end    
  end  
  
  # ===================================================================
  # = httpo://presstee.com/device_communication/check_available_times =
  # ===================================================================
  
  def check_available_times
    # Receive all params from post request, store each one individually
    # Make call to Course model
    response = Course.get_available_tee_times()
    return response
  end
  
  # ===================================================================
  # = httpo://presstee.com/device_communication/book_reservation ======
  # ===================================================================
  
  def book_reservation
    # Receive all params from post request, store each one individually
    # Make call to Reservation model
    reservation = Reservation.book_tee_time(user, course_id, num_golfers, time, date)
    return response
  end
  
  def cancel_reservation
  end      
  
end

