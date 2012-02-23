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
  
=begin

    *** All API Modules should implement the following methods ***
    
    self.book(reservation_info,course,user)   =>  Makes a booking via https and returns a confirmation_code (string) or nil
    self.cancel(reservation)                  =>  Sends a cancel request returns true or false
    self.update(course)                       =>  Queries and updates the latest available tee times data 
    
=end
  
  API_AFFILIATE_ID                     = 'PressTee'
  API_PASSWORD                         = '4PTee1nc'
  API_HOST                             = 'https://www.forereservations.com'
  API_BOOK_URI                         = '/cgi-bin/bk.pl'
  API_CANCEL_URI                       = '/cgi-bin/cancel.pl'
  API_GET_AVAILABLE_URI                = '/cgi-bin/avail2.pl'
  
  DEFAULT_CC_NUM   = "4217639662603493"  
  DEFAULT_CC_YEAR  = "15"
  DEFAULT_CC_MONTH = "11"
  DEFAULT_PHONE    = "5628884454"
  DEFAULT_EMAIL    = 'pressteex@gmail.com'  
  
  # Deep Cliff Fee Matrix = {"split" => [14,16],"holidays" => [1,360],"public" => {"weekday" => [28,21,18],"weekend" => [38,28,22]},"member" => {"weekday" => [21,17,15],"weekend" => [31,22,17]}}
  
  def self.http_get(uri)
    url = URI.parse(API_HOST)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = true
    headers = {}

    begin
      response = http.get(uri, headers)
      puts response
      return response
    rescue
      return nil
    end
  end
  
  def self.book(reservation_info,course,user)
    uri = "#{API_BOOK_URI}?CourseID=#{course.api_course_id}&Date=#{reservation_info[:date]}&Time=#{reservation_info[:time]}&Price=#{reservation_info[:total]}.00&EMail=#{DEFAULT_EMAIL}&FirstName=#{user[:f_name]}&LastName=#{user[:l_name]}&ExpMnth=#{DEFAULT_CC_MONTH}&ExpYear=#{DEFAULT_CC_YEAR}&CreditCard=#{DEFAULT_CC_NUM}&Phone=#{DEFAULT_PHONE}&Quantity=#{reservation_info[:golfers]}&AffiliateID=#{API_AFFILIATE_ID}&Password=#{API_PASSWORD}"
    logger.info uri
    response = self.http_get(uri)
    if XmlSimple.xml_in(response.body).has_key?("confirmation")
      return XmlSimple.xml_in(response.body)["confirmation"][0]
    else
      return nil
    end
  end
  
  def self.cancel(reservation)
    uri = "#{API_CANCEL_URI}?cn=#{reservation.confirmation_code}&a=#{API_AFFILIATE_ID}&p=#{API_PASSWORD}"
    response = self.http_get(uri)
    if XmlSimple.xml_in(response.body).has_key?("confirmation")
      return true
    else
      return false
    end
  end
  
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
  
  
  ## Processes the latest queried data from Course APIs
  def self.process_tee_times_data(response,course)
    ## Convert response to hash
    object = XmlSimple.xml_in(response, { 'KeyAttr' => 'date' })
    converted_response = Hash.new
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

    # Note use of JSON.parse rather than the Rails method json.decode.  This is because json.decode converts the string date to a DateTime...
    previous_response = nil
    if !course.available_times.nil?
      previous_response = JSON.parse(course.available_times)
    end
    
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
          existing = Reservation.find_by_course_id_and_date_and_time_and_created_at(course_id,k,r['t'],(Time.now-5.minute)..Time.now)
          if existing.nil?
            r = Reservation.create(reservation_info)
          end
        end
      end
    end
    
    Rails.cache.write("Updated_Course_"+course_id,course)
    
    return converted_response   
  end
  
  
  
end