require 'pp'
require 'xmlsimple'
require 'json'

class Course < ActiveRecord::Base
  
  has_many :users
  has_many :reservations
  
  # ===============================
  # === DEEP CLIFF GOLF COURSE ====
  # ===============================
  
  Course::DEEP_CLIFF_COURSE_ID         = '1'
  Course::DEEP_CLIFF_COURSE_API        = :fore_reservations
  Course::DEEP_CLIFF_API_AFFILIATE_ID  = '12345'
  Course::DEEP_CLIFF_API_PASSWORD      = 'password'
  Course::DEEP_CLIFF_API_HOST          = 'http://dump-them.appspot.com'
  Course::DEEP_CLIFF_API_URL           = '/cgi-bin/bk.pl'
  DEEP_CLIFF_TIME_SLOTS                = {'06:00' => 4, '06:07' => 4, '06:15' => 4, '06:23' => 4, '06:30' => 4, '06:37' => 4, '06:45' => 4, '06:52' => 4, '07:00' => 4, '07:07' => 4, '07:15' => 4, '07:23' => 4, '07:30' => 4, '07:37' => 4, '07:45' => 4, '07:52' => 4, '08:00' => 4, '08:07' => 4, '08:15' => 4, '08:23' => 4, '08:30' => 4, '08:37' => 4, '08:45' => 4, '08:52' => 4, '09:00' => 4, '09:07' => 4, '09:15' => 4, '09:23' => 4, '09:30' => 4, '09:37' => 4, '09:45' => 4, '09:52' => 4, '10:00' => 4, '10:07' => 4, '10:15' => 4, '10:23' => 4, '10:30' => 4, '10:37' => 4, '10:45' => 4, '10:52' => 4, '11:00' => 4, '11:07' => 4, '11:15' => 4, '11:23' => 4, '11:30' => 4, '11:37' => 4, '11:45' => 4, '11:52' => 4, '12:00' => 4, '12:07' => 4, '12:15' => 4, '12:23' => 4, '12:30' => 4, '12:37' => 4, '12:45' => 4, '12:52'  => 4, '13:00' => 4, '13:07' => 4, '13:15' => 4, '13:23' => 4, '13:30' => 4, '13:37' => 4, '13:45' => 4, '13:52' => 4, '14:00' => 4, '14:07' => 4, '14:15' => 4, '14:23' => 4, '14:30' => 4, '14:37' => 4, '14:45' => 4, '14:52' => 4, '15:00' => 4, '15:07' => 4, '15:15' => 4, '15:23' => 4, '15:30' => 4, '15:37' => 4, '15:45' => 4, '15:52' => 4, '16:00' => 4, '16:07' => 4, '16:15' => 4, '16:23' => 4, '16:30' => 4, '16:37' => 4, '16:45' => 4, '16:52' => 4, '17:00' => 4, '17:07' => 4, '17:15' => 4, '17:23' => 4, '17:30' => 4, '17:37' => 4, '17:45' => 4, '17:52' => 4, '18:00' => 4, '18:07' => 4, '18:15' => 4, '18:23' => 4, '18:30' => 4, '18:37' => 4, '18:45' => 4, '18:52' => 4}
  
  # ================================
  # = EXTEND COURSE CONSTANTS HERE =
  # ================================
    
  Course::SOME_OTHER_COURSE_ID         = '2'
  SOME_OTHER_COURSE_API                = :ez_links
  SOME_OTHER_COURSE_TIME_SLOTS         = {'06:00' => 4, '06:07' => 4, '06:15' => 4, '06:23' => 4, '06:30' => 4, '06:37' => 4, '06:45' => 4, '06:52' => 4, '07:00' => 4, '07:07' => 4, '07:15' => 4, '07:23' => 4, '07:30' => 4, '07:37' => 4, '07:45' => 4, '07:52' => 4, '08:00' => 4, '08:07' => 4, '08:15' => 4, '08:23' => 4, '08:30' => 4, '08:37' => 4, '08:45' => 4, '08:52' => 4, '09:00' => 4, '09:07' => 4, '09:15' => 4, '09:23' => 4, '09:30' => 4, '09:37' => 4, '09:45' => 4, '09:52' => 4, '10:00' => 4, '10:07' => 4, '10:15' => 4, '10:23' => 4, '10:30' => 4, '10:37' => 4, '10:45' => 4, '10:52' => 4, '11:00' => 4, '11:07' => 4, '11:15' => 4, '11:23' => 4, '11:30' => 4, '11:37' => 4, '11:45' => 4, '11:52' => 4, '12:00' => 4, '12:07' => 4, '12:15' => 4, '12:23' => 4, '12:30' => 4, '12:37' => 4, '12:45' => 4, '12:52'  => 4, '13:00' => 4, '13:07' => 4, '13:15' => 4, '13:23' => 4, '13:30' => 4, '13:37' => 4, '13:45' => 4, '13:52' => 4, '14:00' => 4, '14:07' => 4, '14:15' => 4, '14:23' => 4, '14:30' => 4, '14:37' => 4, '14:45' => 4, '14:52' => 4, '15:00' => 4, '15:07' => 4, '15:15' => 4, '15:23' => 4, '15:30' => 4, '15:37' => 4, '15:45' => 4, '15:52' => 4, '16:00' => 4, '16:07' => 4, '16:15' => 4, '16:23' => 4, '16:30' => 4, '16:37' => 4, '16:45' => 4, '16:52' => 4, '17:00' => 4, '17:07' => 4, '17:15' => 4, '17:23' => 4, '17:30' => 4, '17:37' => 4, '17:45' => 4, '17:52' => 4, '18:00' => 4, '18:07' => 4, '18:15' => 4, '18:23' => 4, '18:30' => 4, '18:37' => 4, '18:45' => 4, '18:52' => 4}
  
  # Check available tee times for course, given specific date and time
  # INPUT: get_available_tee_times(1,"07:00","2011-11-22")
  # OUTPUT: {"07:00"=>4, "07:45"=>4, "07:23"=>4, "07:37"=>4, "07:15"=>4, "07:07"=>0, "07:52"=>4, "07:30"=>4}

  def self.get_available_tee_times(course_id,time,date)
    available_tee_slots_for_hour = {}
    tee_slots_for_hour = []
    tee_time_hour = /\d{2}/.match(time)
    
    case course_id
    
    when Course::DEEP_CLIFF_COURSE_ID
      available_tee_slots_for_date = get_available_tee_slots_for_date(course_id,date)
      
      tee_slot_hour_keys = available_tee_slots_for_date.keys
      tee_slot_hour_keys.each do |t|
        if /#{tee_time_hour}:\d{2}/.match(t)
          tee_slots_for_hour << t
        end
      end
      
      tee_slots_for_hour.each do |t|
        available_tee_slots_for_hour[t] = available_tee_slots_for_date[t]
      end
      return available_tee_slots_for_hour
      
    when SOME_OTHER_COURSE_ID

    else
      logger.info "Did not find a valid course with specified course_id in get_available_tee_times function"
    end
  end
  
  # Check available tee times for course and date, given specific course_id and date 
  # INPUT: get_available_tee_slots_for_date(1,"2011-11-22")
  # OUTPUT: {"15:52"=>4, "17:00"=>4, "14:37"=>4, "06:07"=>4 ...}  
  
  def self.get_available_tee_slots_for_date(course_id,date)
    all_available_tee_time_for_date = {}
    booked_tee_times_for_date = get_booked_tee_slots_for_date(course_id,date)
    case course_id
    when Course::DEEP_CLIFF_COURSE_ID
      all_tee_time_slots_for_course = DEEP_CLIFF_TIME_SLOTS
      if !booked_tee_times_for_date.nil?
        all_available_tee_time_for_date = all_tee_time_slots_for_course.merge(booked_tee_times_for_date) {|key, old, new| old-new}
      else
        all_available_tee_time_for_date = all_tee_time_slots_for_course
      end
      return all_available_tee_time_for_date
    when SOME_OTHER_COURSE_ID
    else
      puts "Did not find a valid course with specified course_id get_available_tee_slots_for_date"
    end
  end  
  
  # Check booked tee times for course and date, given specific course_id and date 
  # INPUT: get_booked_tee_slots_for_date(1,"2011-11-22")
  # OUTPUT: {"07:00"=>2, "07:07"=>4}  
  
  def self.get_booked_tee_slots_for_date(course_id,date)
    booked_tee_times_for_date = {}
    booked_tee_times = Reservation.find_all_by_course_id_and_date(course_id,date)
    if booked_tee_times
      booked_tee_times.each do |record|
        if booked_tee_times_for_date.has_key?(record.time)
          booked_tee_times_for_date[record.time] = booked_tee_times_for_date[record.time] + record.golfers
        else
          booked_tee_times_for_date[record.time] = record.golfers
        end
      end
    end  
    return booked_tee_times_for_date
  end  
  

  ## Change format to local use from fore response

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
      course_id = object['avail'][date]['teetime'][0]['courseid'][0]
      val.each do |time|
        time['quantity'] = time['quantity'][0]
        time['time'] = time['time'][0]
        time['courseid'] = time['courseid'][0]
      end
      converted_response.store(date,val)
    end

    
    a = AvailableTeeTimes.find_by_courseid(course_id)
    if !a
      a = AvailableTeeTimes.new
      a.courseid = course_id
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
        set_old = previous_response[k].to_set
        set_new = v.to_set
        bookings = set_old - set_new
        cancels = set_new - set_old
        
        
        logger.info '###########BOOKINGS###########################'
        pp bookings
        bookings.each do |r|
          reservation_info = {:course_id=>course_id, :golfers=>r['quantity'], :time=>r['time'], :date=>k}
          r = EmailReservation.create(reservation_info)
        end

        
        logger.info '###########CANCELS#######Delete These####################'
        pp cancels
        
        # Write Code to Delete cancelled records (To Do)
        
        
        #cancels.each do |r|
        #  rs = EmailReservation.find_all_by_time_and_date(k,r['time'])
        #  rs.each do |s|
            
        #end
        
        logger.info '############END##########################'
      end
    end
    
    
  

=begin
    if !@@previous_response.nil?

      dates.each do |date|
        hsh_length_new = converted_response[date].length
        hsh_length_old = @@previous_response[date].length
        current_data = converted_response[date]
        previous_data = @@previous_response[date]

        
        for i in 0..hsh_length_new-1
          if previous_data[i]['time'][0] == current_data[i]['time'][0]
            converted_response[date][i]['quanity'] = previous_data[i]['quantity'][0].to_i -  current_data[i]['quantity'][0].to_i
            converted_response[date][i]['quanity'] = converted_response[date][i]['quanity'].to_s
          end
        end

        for i in 0..hsh_length_old-1
          if previous_data[i]['time'][0] == current_data[i]['time'][0]
            converted_response[date][i]['quanity'] = previous_data[i]['quantity'][0].to_i -  current_data[i]['quantity'][0].to_i
            converted_response[date][i]['quanity'] = converted_response[date][i]['quanity'].to_s
          end
        end

      end

    end
=end

    ## Storing values for next comparison
    @@previous_response = converted_response

    #puts "RETURNING PROCESSED RESPONSE => #{converted_response}"
    return converted_response   
  end

end
