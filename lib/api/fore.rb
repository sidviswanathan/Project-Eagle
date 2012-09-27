module Fore
  
  # ===================================================================
  # ============== Fore API Communication Module ======================
  # ===================================================================
  
  require 'pp'
  require 'xmlsimple'
  require 'json'
  require 'date'
  require 'time'
  require 'parallel'
  require 'logger'
  
  # self.book(reservation_info,course,user)   =>  Makes a booking via https and returns a confirmation_code (string) or nil
  # self.cancel(reservation)                  =>  Sends a cancel request returns true or false
  # self.update(course)                       =>  Queries and updates the latest available tee times data 

  # ==========================================
  # = SAMPLE API CALLS =======================
  # ==========================================
  
  # Get available tee times for Deep Cliff Golf course, change date to valid date 
  # https://www.forereservations.com/cgi-bin/avail2.pl?a=PressTee&c=1095014&q=0&p=4PTee1nc&d=2012-09-22&t=06:00&et=19:00  
  
  # Get available tee times for Fore Reservation test facility, change date to valid date 
  # https://www.forereservations.com/cgi-bin/avail2.pl?a=PressTee&c=987654&q=0&p=4PTee1nc&d=2012-09-22&t=06:00&et=19:00  
  
  # Book a tee time for Deep CLiff Golf course, change date to a valid date 
  # https://www.forereservations.com/cgi-bin/bk.pl?CourseID=1095014&Date=2012-09-20&Time=06:52&Price=35.00&EMail=pressteex@gmail.com&FirstName=carl&LastName=w&ExpMnth=11&ExpYear=15&CreditCard=4217639662603493&Phone=5628884454&Quantity=1&AffiliateID=PressTee&Password=4PTee1nc
        
  # Cancel a previously booked tee time
  # https://www.forereservations.com/cgi-bin/cancel.pl?cn=XXXXXXXXX&a=PressTee&p=4PTee1nc
  
  API_AFFILIATE_ID                     = 'PressTee'
  API_PASSWORD                         = '4PTee1nc'
  API_HOST                             = 'https://www.forereservations.com'
  API_BOOK_URI                         = '/cgi-bin/bk.pl'
  API_CANCEL_URI                       = '/cgi-bin/cancel.pl'
  API_GET_AVAILABLE_URI                = '/cgi-bin/avail2.pl'
  DEEP_CLIFF_API_COURSE_ID             = '1095014'
  FORE_TEST_FACILITY_COURSE_ID         = '1987654'
  
  DEFAULT_CC_NUM   = "4217639662603493"  
  DEFAULT_CC_YEAR  = "15"
  DEFAULT_CC_MONTH = "11"
  DEFAULT_PHONE    = "5628884454"
  DEFAULT_EMAIL    = 'pressteex@gmail.com'  
  
  TESTING_AUTO_CANCEL = 480
  
  # split 14/16 refers to 2pm and 4 pm changes in price, holiday is Jan 1, December 25
  # DEEP_CLIFF_FEE_MATRIX = {"split" => [14,16],"holidays" => [1,360],"public" => {"weekday" => [28,21,18],"weekend" => [38,28,22]},"member" => {"weekday" => [21,17,15],"weekend" => [31,22,17]}}
  
  def self.http_get(uri)
    url = URI.parse(API_HOST)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    headers = {}

    begin
      response = http.get(uri, headers)
      return response
    rescue
      return nil
    end
  end
    
  # ==========================================
  # = BOOK A TEE TIME ========================
  # ==========================================

  def self.book(reservation_info,course,user)
    puts "-----------------------PRINTING OUT THE RESERVATION INFO"
    pp reservation_info

    
    uri = "#{API_BOOK_URI}?CourseID=#{course.api_course_id}&Date=#{reservation_info[:date]}&Time=#{reservation_info[:time]}&Price=#{reservation_info[:total]}.00&EMail=#{DEFAULT_EMAIL}&FirstName=#{user[:f_name]}&LastName=#{user[:l_name]}&ExpMnth=#{DEFAULT_CC_MONTH}&ExpYear=#{DEFAULT_CC_YEAR}&CreditCard=#{DEFAULT_CC_NUM}&Phone=#{DEFAULT_PHONE}&Quantity=#{reservation_info[:golfers]}&AffiliateID=#{API_AFFILIATE_ID}&Password=#{API_PASSWORD}"
    pp uri
    response = self.http_get(uri)
    pp response.body
    
    begin
      if XmlSimple.xml_in(response.body).has_key?("confirmation")
        ccode = XmlSimple.xml_in(response.body)["confirmation"][0]
        #Auto-cancel tee times that have been booked, every 10 minutes [for testing purposes]   
        #ServerCommunicationController.schedule_cancel(ccode,course.id.to_s,TESTING_AUTO_CANCEL)
        return ccode
      else
        return XmlSimple.xml_in(response.body)
      end
    rescue Exception => e
      puts "ERROR: The self.book API method in fore.rb failed threw an exception"
      #Send admin email
    end
    
  end
  
  # ==========================================
  # = CANCEL A TEE TIME ======================
  # ==========================================
  
  def self.cancel(reservation)    
    uri = "#{API_CANCEL_URI}?cn=#{reservation.confirmation_code}&a=#{API_AFFILIATE_ID}&p=#{API_PASSWORD}"
    puts '------------------------- Cancellation URL:'
    puts uri
    response = self.http_get(uri)
    if XmlSimple.xml_in(response.body).has_key?("confirmation")
      return true
    else
      return false
    end
  end
  
  # ==========================================
  # = UPDATE AVAILABLE TEE TIMES =============
  # ==========================================
  
  # This method Loops through every course and runs the API module for this course
  # This method is called form the ServerCommunication controller which is called by the Google App engine cron that is running
  # This cron runs once every minute to update all the available tee times for the particular course
  
  def self.update(course)
    today = Date.today
    now = Time.now
    if now > Time.parse("17:00")
      today += 1
    end
    @@response_sum = ""
    results = Parallel.map [today,today+1,today+2,today+3,today+4,today+5,today+6,today+7], :in_threads => 4 do |day|
      query = "#{API_GET_AVAILABLE_URI}?a=#{API_AFFILIATE_ID}&c=#{course.api_course_id}&q=0&p=#{API_PASSWORD}&d=#{day.strftime('%Y-%m-%d')}&t=06:00&et=19:00"
      
      url = URI.parse(API_HOST)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = true
      headers = {}
      
      begin
        response = http.get(query, headers)
        dat = response.body.gsub("\n","").split("<avail>")[1]
        if dat.index("teetime").nil?:
  				response = ""
				else
				  response = "<avail date='#{day.strftime("%Y-%m-%d")}'>"+dat
  			end
      rescue
        response = ""
      end
      
    end
    self.process_tee_times_data("<results>#{results.join}</results>",course)
  end
  
  # Returns the price for a tee time
  def self.get_green_fee(date,time,fee_matrix)
    d = Date.strptime(date,"%Y-%m-%d").strftime("%u").to_i
    t = time.split(":")[0].to_i
    book_day = "weekday"
    book_type = "public"
    
    if d > 5
      book_day = "weekend"
    end
    
    if t < fee_matrix['split'][0]
      price = fee_matrix[book_type][book_day][0]
    elsif t < fee_matrix['split'][1]
      price = fee_matrix[book_type][book_day][1]
    else
      price = fee_matrix[book_type][book_day][2]
    end
    
    return price
  end
  
  # Processes the latest queried data from Course APIs and modifies it into a new hash structure 
  def self.process_tee_times_data(response,course)
    object = XmlSimple.xml_in(response, { 'KeyAttr' => 'date' })
    converted_response = Hash.new
    if !object.has_key?('avail') 
      puts "ERROR: The update tee time method failed for course with id: #{course.id.to_s}"
      #Send an admin email out to notify of failed update times API call 
      return converted_response
    end  
    dates = object['avail'].keys
    course_id = course.id.to_s
    fee_matrix = JSON.parse(course.fee_matrix)
    
    dates.each do |date|
      val = object['avail'][date]['teetime']
      
      current_hour = 6
      hours = {6=>[],7=>[],8=>[],9=>[],10=>[],11=>[],12=>[],13=>[],14=>[],15=>[],16=>[],17=>[],18=>[],19=>[]}
      val.each do |time|
        time['q'] = time['quantity'][0]
        time['t'] = time['time'][0]
        time.delete("courseid")
        time.delete("quantity")
        time.delete("time")
        time['p'] = get_green_fee(date,time['t'],fee_matrix)
        
        if time['t'].split(":")[0].to_i == current_hour
          hours[current_hour].push(time)
        else
          current_hour = time['t'].split(":")[0].to_i
          hours[current_hour].push(time)
        end
      end
      converted_response.store(date,{"day"=>val,"hours"=>hours})
    end

    previous_response = nil
    if !course.available_times.nil?
      previous_response = JSON.parse(course.available_times)
    end
    
    #Saves/updates the modified hash structure into the databse for the Course record
    course.available_times = converted_response.to_json
    course.save
    if !previous_response.nil?
      converted_response.each_pair do |k,v|
        set_old = previous_response[k]["day"].to_set
        set_new = v["day"].to_set
        
        bookings = set_old - set_new
        cancels = set_new - set_old
        
        bookings.each do |r|
          cancels.each do |c|
            if c['t'] == r['t']
              r['q'] = (r['q'].to_i - c['q'].to_i).to_s
            end
          end
          reservation_info = {:course_id=>course_id, :golfers=>r['q'], :time=>r['t'], :date=>k, :booking_type=>"Standard"}
          # This is checking for an edge case where someone walks in and books a tee time in the last 60 seconds
          # Time.now time zone in the app instance != created_at time zone in database, which is causing 
          # Also note that in environment.rb, config.time_zone is set to UTC
          # This block of code allows the app to track all bookings that came in to the course outside of the app, and also tracks when the booking was created in comparison to the actual tee time (i.e. how far in advance do people book?)
          # This call becomes very expensive over time as the number of Reservation records increases
          # existing = Reservation.find_by_course_id_and_date_and_time_and_created_at(course_id,k,r['t'],((Time.now+7.hours)-5.minute)..(Time.now+7.hours))
          # if existing.nil?
          existing_reservation = Reservation.find_all_by_date_and_time_and_course_id(k,r['t'],course_id)
          puts 'DID I FIND AND EXISTING RESERVATION OR NOT????'
          pp existing_reservation
          r = Reservation.create(reservation_info) unless existing_reservation
          # end
        end
      end
    end
    
    Rails.cache.write("Updated_Course_"+course_id,course)
    return converted_response   
  end    
  
end