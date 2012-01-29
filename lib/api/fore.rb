module Fore
  
  require 'pp'
  require 'xmlsimple'
  require 'json'
  require 'date'
  require 'time'
  require 'parallel'  
  
  API_AFFILIATE_ID                     = 'PressTee'
  API_PASSWORD                         = '4PTee1nc'
  API_HOST                             = 'https://www.forereservations.com'
  API_BOOK_URI                         = '/cgi-bin/bk.pl'
  API_CANCEL_URI                       = '/cgi-bin/cancel.pl'
  API_GET_AVAILABLE_URI                = '/cgi-bin/avail2.pl'
  
  
  # OLd Fee Matrix = {"split" => [14,16],"public" => {"weekday" => [28,21,18],"weekend" => [38,28,22]},"member" => {"weekday" => [21,17,15],"weekend" => [31,22,17]}}
  def self.book(params)
    
  end
  
  def self.cancel(params)
    
  end
  
  
  
  def self.update(course)
    
    today = Date.today
    now = Time.now
    if now > Time.parse("17:00")
      today += 1
    end
    @@response_sum = ""
    results = Parallel.map [today,today+1,today+2,today+3,today+4,today+5,today+6], :in_threads => 4 do |day|
      query = "#{API_GET_AVAILABLE_URI}?a=#{API_AFFILIATE_ID}&c=#{course.api_course_id}&q=0&p=#{API_PASSWORD}&d="+day.strftime("%Y-%m-%d")+"&t=08:00&et=19:00" 
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
				  response = "<avail date='"+day.strftime("%Y-%m-%d")+"'>"+dat
  			end
        
      rescue
        response = ""
      end

     
    end
    self.process_tee_times_data(results.join,course)
    
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
    #pp object
    ## Get all dates from response
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
    if !course.data.nil?
      previous_response = JSON.parse(course.data)
    end
    

    course.data = converted_response.to_json
    course.save
    if !previous_response.nil?
      converted_response.each_pair do |k,v|
        set_old = previous_response[k]["day"].to_set
        set_new = v["day"].to_set
        bookings = set_old - set_new
        cancels = set_new - set_old

        logger.info '###########BOOKINGS###########################'
        pp bookings

        bookings.each do |r|
          reservation_info = {:course_id=>course_id, :golfers=>r['q'], :time=>r['t'], :date=>k}
          r = EmailReservation.create(reservation_info)
        end
      end
    end
    
    Rails.cache.write("Updated_Course_"+course_id,course)
    
    return converted_response   
  end
  
  
  
end