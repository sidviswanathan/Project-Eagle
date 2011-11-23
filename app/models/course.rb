class Course < ActiveRecord::Base
  
  has_many :users
  has_many :reservations
  
  # ===============================
  # === DEEP CLIFF GOLF COURSE ====
  # ===============================
  
  Course::DEEP_CLIFF_COURSE_ID          = 1
  DEEP_CLIFF_COURSE_API         = :fore_reservations
  DEEP_CLIFF_TIME_SLOTS         = {'06:00' => 4, '06:07' => 4, '06:15' => 4, '06:23' => 4, '06:30' => 4, '06:37' => 4, '06:45' => 4, '06:52' => 4, '07:00' => 4, '07:07' => 4, '07:15' => 4, '07:23' => 4, '07:30' => 4, '07:37' => 4, '07:45' => 4, '07:52' => 4, '08:00' => 4, '08:07' => 4, '08:15' => 4, '08:23' => 4, '08:30' => 4, '08:37' => 4, '08:45' => 4, '08:52' => 4, '09:00' => 4, '09:07' => 4, '09:15' => 4, '09:23' => 4, '09:30' => 4, '09:37' => 4, '09:45' => 4, '09:52' => 4, '10:00' => 4, '10:07' => 4, '10:15' => 4, '10:23' => 4, '10:30' => 4, '10:37' => 4, '10:45' => 4, '10:52' => 4, '11:00' => 4, '11:07' => 4, '11:15' => 4, '11:23' => 4, '11:30' => 4, '11:37' => 4, '11:45' => 4, '11:52' => 4, '12:00' => 4, '12:07' => 4, '12:15' => 4, '12:23' => 4, '12:30' => 4, '12:37' => 4, '12:45' => 4, '12:52'  => 4, '13:00' => 4, '13:07' => 4, '13:15' => 4, '13:23' => 4, '13:30' => 4, '13:37' => 4, '13:45' => 4, '13:52' => 4, '14:00' => 4, '14:07' => 4, '14:15' => 4, '14:23' => 4, '14:30' => 4, '14:37' => 4, '14:45' => 4, '14:52' => 4, '15:00' => 4, '15:07' => 4, '15:15' => 4, '15:23' => 4, '15:30' => 4, '15:37' => 4, '15:45' => 4, '15:52' => 4, '16:00' => 4, '16:07' => 4, '16:15' => 4, '16:23' => 4, '16:30' => 4, '16:37' => 4, '16:45' => 4, '16:52' => 4, '17:00' => 4, '17:07' => 4, '17:15' => 4, '17:23' => 4, '17:30' => 4, '17:37' => 4, '17:45' => 4, '17:52' => 4, '18:00' => 4, '18:07' => 4, '18:15' => 4, '18:23' => 4, '18:30' => 4, '18:37' => 4, '18:45' => 4, '18:52' => 4}
  
  # ================================
  # = EXTEND COURSE CONSTANTS HERE =
  # ================================
    
  SOME_OTHER_COURSE_ID          = 2
  SOME_OTHER_COURSE_API         = :ez_links
  SOME_OTHER_COURSE_TIME_SLOTS  = {'06:00' => 4, '06:07' => 4, '06:15' => 4, '06:23' => 4, '06:30' => 4, '06:37' => 4, '06:45' => 4, '06:52' => 4, '07:00' => 4, '07:07' => 4, '07:15' => 4, '07:23' => 4, '07:30' => 4, '07:37' => 4, '07:45' => 4, '07:52' => 4, '08:00' => 4, '08:07' => 4, '08:15' => 4, '08:23' => 4, '08:30' => 4, '08:37' => 4, '08:45' => 4, '08:52' => 4, '09:00' => 4, '09:07' => 4, '09:15' => 4, '09:23' => 4, '09:30' => 4, '09:37' => 4, '09:45' => 4, '09:52' => 4, '10:00' => 4, '10:07' => 4, '10:15' => 4, '10:23' => 4, '10:30' => 4, '10:37' => 4, '10:45' => 4, '10:52' => 4, '11:00' => 4, '11:07' => 4, '11:15' => 4, '11:23' => 4, '11:30' => 4, '11:37' => 4, '11:45' => 4, '11:52' => 4, '12:00' => 4, '12:07' => 4, '12:15' => 4, '12:23' => 4, '12:30' => 4, '12:37' => 4, '12:45' => 4, '12:52'  => 4, '13:00' => 4, '13:07' => 4, '13:15' => 4, '13:23' => 4, '13:30' => 4, '13:37' => 4, '13:45' => 4, '13:52' => 4, '14:00' => 4, '14:07' => 4, '14:15' => 4, '14:23' => 4, '14:30' => 4, '14:37' => 4, '14:45' => 4, '14:52' => 4, '15:00' => 4, '15:07' => 4, '15:15' => 4, '15:23' => 4, '15:30' => 4, '15:37' => 4, '15:45' => 4, '15:52' => 4, '16:00' => 4, '16:07' => 4, '16:15' => 4, '16:23' => 4, '16:30' => 4, '16:37' => 4, '16:45' => 4, '16:52' => 4, '17:00' => 4, '17:07' => 4, '17:15' => 4, '17:23' => 4, '17:30' => 4, '17:37' => 4, '17:45' => 4, '17:52' => 4, '18:00' => 4, '18:07' => 4, '18:15' => 4, '18:23' => 4, '18:30' => 4, '18:37' => 4, '18:45' => 4, '18:52' => 4}
  
  # Check available tee times for course, given specific date and time
  # INPUT:   
  # SUCCESS OUTPUT:  
  # FAILURE OUTPUT:  

  def self.get_available_tee_times(course_id,time,date)
    case course_id
    when DEEP_CLIFF_COURSE_ID
      available_tee_slots_for_date = get_available_tee_slots_for_date(course_id,date)
    when SOME_OTHER_COURSE_ID
    else
      puts "Did not find a valid course with specified course_id"
    end
  end
  
  # Check available tee times for course and date, given specific course_id and date 
  # INPUT:   
  # SUCCESS OUTPUT:  
  # FAILURE OUTPUT:
  
  def get_available_tee_slots_for_date(course_id,date)
    booked_tee_times_for_date = get_booked_tee_slots_for_date(course_id,date)
    available_tee_time_for_date = {}
    case course_id
    when DEEP_CLIFF_COURSE_ID
      all_tee_time_slots = DEEP_CLIFF_TIME_SLOTS
      
    when SOME_OTHER_COURSE_ID
    else
      puts "Did not find a valid course with specified course_id"
    end
  end  
  
  # Check booked tee times for course and date, given specific course_id and date 
  # INPUT: get_booked_tee_slots_for_date(1,"2011-11-22")   
  # OUTPUT:  
  
  def get_booked_tee_slots_for_date(course_id,date)
    booked_tee_times_for_date = {}
    booked_tee_times = Reservation.find_all_by_course_id_and_date(course_id,date)
    if booked_tee_times
      booked_tee_times.each do |record|
        if booked_tee_times_for_date.has_key?(record.time)
          booked_tee_times_for_date[record.time] = booked_tee_times_for_date[record.tee_slot] + record.golfers
        else
          booked_tee_times_for_date[record.time] = record.golfers
        end
      end
    end  
    return booked_tee_times_for_date
  end  
  
end
