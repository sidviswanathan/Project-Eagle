class Reservation < ActiveRecord::Base
  belongs_to :course
  belongs_to :user
  
  # Book reservation record, creates a Reservation record, connects to user
  # INPUT:   
  # SUCCESS OUTPUT:  
  # FAILURE OUTPUT:  

  def self.book_tee_time(email, course_id, golfers, time, date)
    reservation_info = {:course_id=>course_id, :golfers=>golfers, :time=>time, :date=>date}
    u = User.find_by_email(email)
    if u 
      r = Reservation.create(reservation_info)
      r.user = u
      r.save
    else 
      return nil 
    end       
    if r; return r else return nil end
  end  
  
end
