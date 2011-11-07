class DeviceCommunicationController < ApplicationController
  
  def login
    # Receive all params from post request, store each one individually
    # Make call to User model
    response = login()
    return response
  end  
  
  def check_available_times
    # Receive all params from post request, store each one individually
    # Make call to Course model
    response = Course.get_available_tee_times()
    return response
  end
  
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
