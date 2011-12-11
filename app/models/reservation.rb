require "net/http"
require "net/https"
require 'pp'

class Reservation < ActiveRecord::Base

  belongs_to :course
  belongs_to :user

  validates_numericality_of :golfers, :greater_than => 1, :less_than => 5, :message => "Invalid number of golfers"
  
  # Book reservation record, creates a Reservation record, connects to user
  # INPUT:   
  # OUTPUT:  

  def self.book_tee_time(email, course_id, golfers, time, date)
    reservation_info = {:course_id=>course_id, :golfers=>golfers, :time=>time, :date=>date}
    u = User.find_by_email(email)
    if u 
      r = Reservation.create(reservation_info)
      r.user = u
      r.save
    else 
      logger.info "Did not find a user record with the email #{email}"
      return nil 
    end       
    if r.save; return r else return nil end
  end 
  
  
  
   
  
end
