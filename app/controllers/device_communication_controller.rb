class DeviceCommunicationController < ApplicationController
  
  # These are the clinet API endpoints for all devices communicating witht the Prestee server
  # Below is the expected format for paramters received from all client devices

  # course_id   => 1                  (Integer)   As defined in the Course model
  # num_golfers => 2                  (Integer    Range between 2-4
  # time        => '07:14'            (String)    24-hour time format
  # date        => '06-05-11'         (String)
  # fName       => 'first_name'       (String)
  # lName       => 'last_name'        (String)
  # email       => 'name@domain.com'  (String)
  
  # ===================================================================
  # = httpo://presstee.com/device_communication/login =================
  # ===================================================================
  
  def login
    # Receive all params from post request, store each one individually
    # Make call to User model
    response = login()
    return response
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
    response = Reservation.book_tee_times()
    return response
  end
  
  def cancel_reservation
  end      
  
end

# ==========================================
# = DEFINE STANDARD RESPONSE OBJECT FORMAT =
# ==========================================

# render :json => {:status=>'success or failure',
#                  :message=>'Insert comment here',
#                  :response=>"insert response object here"
#                 }
