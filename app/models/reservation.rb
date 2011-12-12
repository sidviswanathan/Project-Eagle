require "net/http"
require "net/https"

class Reservation < ActiveRecord::Base

  belongs_to :course
  belongs_to :user

  validates_numericality_of :golfers, :greater_than => 1, :less_than => 5, :message => "Invalid number of golfers"
  
  # Book reservation record, creates a Reservation record, connects to user
  # INPUT:   
  # OUTPUT:   

  def self.book_tee_time(email, course_id, golfers, time, date)
    reservation_info = {:course_id=>course_id, :golfers=>golfers, :time=>time, :date=>date}
    
    # Make the API reservation call here
    booking = book_time_via_api(reservation_info)
    #confirmation_code = convert booking to hash and get the confirmation code 
    
    if booking
      u = User.find_by_email(email)
      if u 
        r = Reservation.create(reservation_info)
        r.booking_type = 'IPhone'
        r.confirmation_code = '12345'
        r.user = u
        r.save
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
  
  # Book reservation through course's reservation system via corresponding API, as defined in COurse model
  # INPUT: http://dump-them.appspot.com/cgi-bin/bk.pl?CourseID=1&Date=2011-12-19&Time=06:08&Email=arjun.vasan@gmail.com&Quantity=2&AffiliateID=029f2fw&Password=eagle  
  # OUTPUT:  
  
  def self.book_time_via_api(reservation_info)
    
    case course_id
    
    when Course::DEEP_CLIFF_COURSE_ID
      book_time_via_fore_reservations_api(reservation_info)
    when Course::SOME_OTHER_COURSE_ID 
      # Call function corresponding to the courses API
    else
      logger.info "Did not find a valid course with specified course_id in book_time_via_api function"
      return nil
    end      
    
  end  
  
  #IMPLEMENT: Move this to a separate module file for all Fore API calls.  Every API should have it's own module
  #SAMPLE: response = http.post("http://dump-them.appspot.com/cgi-bin/bk.pl?CourseID=1&Date=2011-12-19&Time=06:08&Email=arjun.vasan@gmail.com&Quantity=2&AffiliateID=029f2fw&Password=eagle", headers)
  
  
  
  def book_time_via_fore_reservations_api(reservation_info)
    
    url = URI.parse(Course::DEEP_CLIFF_API_HOST)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = false
    headers = {}

    begin
      response = http.post("#{Course::DEEP_CLIFF_API_URL}?=CourseID=#{reservation_info[:course_id]}&Date=#{reservation_info[:date]}&Time=#{reservation_info[:time]}&Email=#{reservation_info[:email]}&Quantity=#{reservation_info[:golfers]}&AffiliateID=#{Course::DEEP_CLIFF_API_AFFILIATE_ID}&Password=#{Course::DEEP_CLIFF_API_PASSWORD}", headers)
    rescue
      return nil
    end
    
    if response; return response else return nil end    
  end
     
end
