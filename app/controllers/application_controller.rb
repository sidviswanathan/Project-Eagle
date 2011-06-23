# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  # Post send_object
  def post_response(post_data)
    respond_to do |format|
      format.json { render :json => post_data }
    end
  end


  def create_user(username, name)
    puts "Inside create_user"
    create = User.new
    create.email=username 
    create.f_name=name
    if create.save
      user = User.find_by_email(username)
      puts "User saved -- #{username}"
      return user.id
    else
      respond_to do |format|
        format.json  { render :json => create.errors, :status => :unprocessable_entity }
      end
      puts "Error in creating user"
    end
  end


  def create_reservation(user_email, uname, date, tee_time_slot, golfers, course)
    if user_email.blank?
      puts "No Username received"
      return "Unknown_user"
    else
      puts "Find user by email"
      puts user_email
      user = User.find_by_email(user_email)

      if user.blank?
        puts "Cannot find user -- Creating User"
        uid = create_user(user_email, uname)
        puts "User id:"
        puts uid
      else
        puts "Found User"
        puts "User id:"
        uid=user.id
        puts uid
        puts date
      end
    end

    if !uid.blank?
      @saved_tee_slot = []
      create = Reservation.new
      create.user_id=uid
      create.date=date
      create.tee_slot=tee_time_slot
      create.golfers=golfers
      create.course_id=course
      create.save

      @saved_tee_slot << tee_time_slot
      return @saved_tee_slot
      puts "Reservation recorded -- #{tee_time_slot}"
      puts "----- Congratulations you have successfully reserved a tee slot -----"
      puts "Please wait for confirmation"
    end
  end


  def check_for_reservation(date, tee_slot, course)
    if Reservation.find_by_date(date, :conditions => {:tee_slot => tee_slot}).nil?
      puts "--- Requested Tee slot #{tee_slot} is free for date #{date} ---"
      return "success"
    else
      return "fail"
    end
  end


  def show_available_tee_slots_for_date(date, course)
    puts "--- Calculating tee slots on given date #{date} ---"
    puts "--- Checking for free Tee Slots ---"
    @tee_slots_for_date = Reservation.find_all_by_date(date)
    @tee_slots_booked_for_date = []

    @tee_slots_for_date.each do |record|
      @tee_slots_booked_for_date << record.tee_slot
    end

    puts "--- All tee slots reserved for given date #{date} ---"
    puts @tee_slots_booked_for_date

    puts "--- Calculating free tee slots for given date #{date} ---"
    @all_tee_slots = $tee_slots
    free_slots_for_date = @all_tee_slots - @tee_slots_booked_for_date
    puts free_slots_for_date

    return free_slots_for_date
  end


  def show_available_tee_slots_for_hour(date, tee_slot_hour, course)
    tee_slots_for_date = show_available_tee_slots_for_date(date, course)
    hour_slot = /\d{2}/.match(tee_slot_hour)

    @tee_slots_for_hour = []
    tee_slots_for_date.each do |t|
      if /#{hour_slot}:\d{2}/.match(t)
        @tee_slots_for_hour << t
      end
    end
    puts "--- Calculating free tee slots for given date #{date} and hour #{tee_slot_hour} ---"
    puts @tee_slots_for_hour

    return @tee_slots_for_hour
  end

end
