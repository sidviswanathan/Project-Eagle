require 'pp'
require 'xmlsimple'
require 'json'
require 'date'

class Course < ActiveRecord::Base
  
  has_many :users
  has_many :reservations
  
  ##  This is necessary due to running the cron job on appengine.  When appengine queries fore (for example), the reply is data containing the "1987654" course_id.  
  ##  When we start doing the cron job from heroku, this will no longer be needed.
  TEMP_COURSE_ID_MAP = {
    "1987654" => "1"
  }
  
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
  def self.process_tee_times_data(response)
    ## Convert response to hash
    object = XmlSimple.xml_in(response, { 'KeyAttr' => 'date' })
    converted_response = Hash.new
    #pp object
    ## Get all dates from response
    dates = object['avail'].keys
    
    course_id = TEMPORARY_API_ID_TO_ID_MAP[object['avail'][dates[0]]['teetime'][0]['courseid'][0]]
    
    course = Rails.cache.fetch("Course_"+course_id) {Course.find(course_id.to_i)}
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

    
    a = AvailableTimes.find_by_course_id(course_id)
    if !a
      a = AvailableTimes.new
      a.course_id = course_id
      a.data = converted_response.to_json
      a.save
    else
      # Note use of JSON.parse rather than the Rails method json.decode.  This is because json.decode converts the string date to a DateTime...
      previous_response = JSON.parse(a.data)
      if course_id == '1'
        pp converted_response
      end
      a.data = converted_response.to_json
      a.save
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
    Rails.cache.write("LatestAvailableTimes_"+course_id,a)
    
    # Storing values for next comparison
    @@previous_response = converted_response

    return converted_response   
  end

end
