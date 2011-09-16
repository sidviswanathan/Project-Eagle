# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  $tee_slots = TEE_TIME_SLOTS_DEEP_CLIFF


  # Post send_object
  def post_response(post_data)
    respond_to do |format|
      format.json { render :json => post_data }
    end
  end

  ## User login form ##
  def user_sign_in
    request_user = params[:email]
    request_uname = params[:fName]
    create_user(request_user, request_uname)
    post_response("User successfully created")
  end


  ## User create function ##
  def create_user(username, name)
    puts "Inside create_user"
    if User.find_by_email(username).blank?
      create = User.new
      create.email=username
      create.f_name=name
      if create.save
        user = User.find_by_email(username)
        puts "User saved -- #{username} -- #{user.id}"
        return user.id 
      else
        puts "Error in creating user"
        post_response(create.errors)
#        respond_to do |format|
#          format.json  { render :json => create.errors, :status => :unprocessable_entity }
#        end
      end
    else
      puts "User already exists"
      post_response("User already exists")
    end
  end


  ## Reservation create function ##
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

    if !uid.blank? && !tee_time_slot.blank? && !golfers.blank?
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
    else
      puts "mandatory fied missing"
      return "Mandatory field missing!"
    end
  end

  def check_for_reservation(date, tee_slot, slots, course)
    puts "slots -- #{slots}"
    puts "tee_slot -- #{tee_slot}"
    if Reservation.find_by_date(date, :conditions => {:tee_slot => tee_slot}).nil?
      puts "--- Requested Tee slot #{tee_slot} is free for date #{date} ---"
      return "success"
    else
      if Reservation.find_all_by_date(date, :conditions => {:tee_slot => tee_slot}).count<2
        record = Reservation.find_by_date(date, :conditions => {:tee_slot => tee_slot})
        r = record.golfers + slots.to_i
        if r > 4
          return "Fail"
        else
          return "success"
        end
      else
        return "Fail"
      end
    end
  end

  def show_booked_tee_slots_for_date(date, course)
    @tee_slots_booked_for_date = {}

    ## Getting all tee slots for date
    puts "--- Calculating tee slots on given date #{date} ---"
    @tee_slots_for_date = Reservation.find_all_by_date(date)

    ## Creating an hash for booked times
    puts "--- All tee slots reserved for given date #{date} ---"
    @tee_slots_for_date.each do |record|
      if !@tee_slots_booked_for_date.has_key?(record.tee_slot)
        @tee_slots_booked_for_date[record.tee_slot] = record.golfers
      else
        @tee_slots_booked_for_date[record.tee_slot] = @tee_slots_booked_for_date[record.tee_slot] + record.golfers
      end
    end
    puts "@tee_slots_booked_for_date = #{@tee_slots_booked_for_date}"
    return @tee_slots_booked_for_date
  end


  def show_available_tee_slots_for_date(date, course)
    @free_slots_for_date = {}
    @all_tee_slots = $tee_slots

    @tee_slots_booked_for_date = show_booked_tee_slots_for_date(date, course)
    puts "@tee_slots_booked_for_date = #{@tee_slots_booked_for_date}"
    ## Comparing with available times and their tee slots
    if !@tee_slots_booked_for_date.nil?
      @free_slots_for_date = @all_tee_slots.merge(@tee_slots_booked_for_date) {|key, old, new| old-new}
    else
      @free_slots_for_date = @all_tee_slots
    end
    puts "--- Printing all free tee slots ---"
    puts @free_slots_for_date
    return @free_slots_for_date
  end


  def show_available_tee_slots_for_hour(date, tee_slot_hour, course)
    @hour_slots = []
    @all_tee_slots = []
    @tee_slots_for_date = {}
    @tee_slots_for_hour = {}

    ## Function call to get all available tee slots for that specific date
    @tee_slots_for_date = show_available_tee_slots_for_date(date, course)

    ## Getting hour slot requested by user
    hour = /\d{2}/.match(tee_slot_hour)

    ## Collecting all hour slots
    @total_tee_slots = $tee_slots.keys
    @total_tee_slots.each do |t|
      if /#{hour}:\d{2}/.match(t)
        @hour_slots << t
      end
    end

    ## Making hash for post response
    @hour_slots.each do |t|
        @tee_slots_for_hour[t] = @tee_slots_for_date[t]
    end

    puts "--- Calculating free tee slots for given date #{date} and hour #{tee_slot_hour} ---"
    puts @tee_slots_for_hour

    return @tee_slots_for_hour
  end

  def cancel_reservation(email, date, tee_slot)
    @tee_slots_for_cancel = []

    #user = User.find_by_email(email)
    #puts "USER IS #{user}"
    #uid = user.id
    ## ALLOWING CANCELLATION FOR ANY USER ##

    puts "Info for deletion email #{email} date #{date} and tee slot #{tee_slot}"
    if !Reservation.find_all_by_date(date, :conditions => {:tee_slot => tee_slot}).nil?
      @tee_slots_for_cancel << Reservation.find_by_date(date, :conditions => {:tee_slot => tee_slot})
      @tee_slots_for_cancel[0].destroy
    else
      puts "Cannot find reservation to delete"
    end
  end

end
