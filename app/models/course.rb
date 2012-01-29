require 'pp'
require 'xmlsimple'
require 'json'
require 'date'

class Course < ActiveRecord::Base
  
  has_many :users
  has_many :reservations
  
  # ===============================
  # === DEEP CLIFF GOLF COURSE ====
  # ===============================
  

  GREEN_FEES                           = {
    "1987654" => {
      "split" => [14,16],
      "public" => {
        "weekday" => [28,21,18],
        "weekend" => [38,28,22]
      },
      "member" => {
        "weekday" => [21,17,15],
        "weekend" => [31,22,17]
      }
    }
  }

  def self.get_green_fee(date,time,course_id)
    d = Date.strptime(date,"%Y-%m-%d").strftime("%u").to_i
    t = time.split(":")[0].to_i
    course_fee_schedule = GREEN_FEES[course_id]
    book_day = "weekday"
    book_type = "public"
    
    if d > 5
      book_day = "weekend"
    end
    
    if t < course_fee_schedule['split'][0]
      price = course_fee_schedule[book_type][book_day][0]
    elsif t < course_fee_schedule['split'][1]
      price = course_fee_schedule[book_type][book_day][1]
    else
      price = course_fee_schedule[book_type][book_day][2]
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
    course_id = "1"
    dates.each do |date|
      val = object['avail'][date]['teetime']
      #puts object['avail'][date]
      course_id = object['avail'][date]['teetime'][0]['courseid'][0]
      current_hour = 6
      hours = {6=>[],7=>[],8=>[],9=>[],10=>[],11=>[],12=>[],13=>[],14=>[],15=>[],16=>[],17=>[],18=>[],19=>[]}
      val.each do |time|
        time['q'] = time['quantity'][0]
        time['t'] = time['time'][0]
        time.delete("courseid")
        time.delete("quantity")
        time.delete("time")
        time['p'] = get_green_fee(date,time['t'],course_id)
        
        if time['t'].split(":")[0].to_i == current_hour
          hours[current_hour].push(time)
        else
          current_hour += 1
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
