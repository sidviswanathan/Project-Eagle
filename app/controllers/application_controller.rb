# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  protect_from_forgery # See ActionController::RequestForgeryProtection for details

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password
  $tee_slots = TEE_TIME_SLOTS_DEEP_CLIFF
  
  # This method checks to see if there is any discounted pricing available for that day
  # Otherwise, returns standard pricing for that day
  def self.display_pricing(date,time,app)    
    discounted_pricing = JSON.parse(app.course.discounted_pricing)
    if discounted_pricing.has_key?(date)
      discounted_pricing[date].each do |d|
        if d['t'] == time['t']
          return "<font color='#2bcb07'>#{d['s']}&nbsp;&nbsp;&nbsp;</font>$#{d['p'].to_s}"
        end    
      end
      return time['p'].to_s         
    else
      return time['p'].to_s
    end  
    
    # CHanging pricing for 1 Day
    #p = {"2012-11-22"=>[{"p"=>38, "q"=>"4", "t"=>"07:22"},{"p"=>38, "q"=>"4", "t"=>"07:30"},{"p"=>38, "q"=>"4", "t"=>"07:45"},{"p"=>38, "q"=>"4", "t"=>"07:52"}]}
    
    # CHanging pricing for 2 days
    #p = {"2012-11-22"=>[{"p"=>38, "q"=>"4", "t"=>"06:00"},{"p"=>38, "q"=>"4", "t"=>"06:07"}],"2012-11-23"=>[{"p"=>88, "q"=>"4", "t"=>"07:00"},{"p"=>88, "q"=>"4", "t"=>"07:07"}]}
    
    # Thanksgiving pricing
    # p = {"2012-11-22"=>[{"p"=>38, "q"=>"4", "t"=>"06:00"},{"p"=>38, "q"=>"4", "t"=>"06:07"},{"p"=>38, "q"=>"4", "t"=>"06:15"},{"p"=>38, "q"=>"4", "t"=>"06:22"},{"p"=>38, "q"=>"4", "t"=>"06:30"},{"p"=>38, "q"=>"4", "t"=>"06:37"},{"p"=>38, "q"=>"4", "t"=>"06:45"},{"p"=>38, "q"=>"4", "t"=>"06:52"},{"p"=>38, "q"=>"4", "t"=>"07:00"},{"p"=>38, "q"=>"4", "t"=>"07:07"},{"p"=>38, "q"=>"4", "t"=>"07:15"},{"p"=>38, "q"=>"4", "t"=>"07:22"},{"p"=>38, "q"=>"4", "t"=>"07:30"},{"p"=>38, "q"=>"4", "t"=>"07:37"},{"p"=>38, "q"=>"4", "t"=>"07:45"},{"p"=>38, "q"=>"4", "t"=>"07:52"},{"p"=>38, "q"=>"4", "t"=>"08:00"},{"p"=>38, "q"=>"4", "t"=>"08:07"},{"p"=>38, "q"=>"4", "t"=>"08:15"},{"p"=>38, "q"=>"4", "t"=>"08:22"},{"p"=>38, "q"=>"4", "t"=>"08:30"},{"p"=>38, "q"=>"4", "t"=>"08:37"},{"p"=>38, "q"=>"4", "t"=>"08:45"},{"p"=>38, "q"=>"4", "t"=>"08:52"},{"p"=>38, "q"=>"4", "t"=>"09:00"},{"p"=>38, "q"=>"4", "t"=>"09:07"},{"p"=>38, "q"=>"4", "t"=>"09:15"},{"p"=>38, "q"=>"4", "t"=>"09:22"},{"p"=>38, "q"=>"4", "t"=>"09:30"},{"p"=>38, "q"=>"4", "t"=>"09:37"},{"p"=>38, "q"=>"4", "t"=>"09:45"},{"p"=>38, "q"=>"4", "t"=>"09:52"},{"p"=>38, "q"=>"4", "t"=>"10:00"},{"p"=>38, "q"=>"4", "t"=>"10:07"},{"p"=>38, "q"=>"4", "t"=>"10:15"},{"p"=>38, "q"=>"4", "t"=>"10:22"},{"p"=>38, "q"=>"4", "t"=>"10:30"},{"p"=>38, "q"=>"4", "t"=>"10:37"},{"p"=>38, "q"=>"4", "t"=>"10:45"},{"p"=>38, "q"=>"4", "t"=>"10:52"},{"p"=>38, "q"=>"4", "t"=>"11:00"},{"p"=>38, "q"=>"4", "t"=>"11:07"},{"p"=>38, "q"=>"4", "t"=>"11:15"},{"p"=>38, "q"=>"4", "t"=>"11:22"},{"p"=>38, "q"=>"4", "t"=>"11:30"},{"p"=>38, "q"=>"4", "t"=>"11:37"},{"p"=>38, "q"=>"4", "t"=>"11:45"},{"p"=>38, "q"=>"4", "t"=>"11:52"},{"p"=>38, "q"=>"4", "t"=>"12:00"},{"p"=>38, "q"=>"4", "t"=>"12:07"},{"p"=>38, "q"=>"4", "t"=>"12:15"},{"p"=>38, "q"=>"4", "t"=>"12:22"},{"p"=>38, "q"=>"4", "t"=>"12:30"},{"p"=>38, "q"=>"4", "t"=>"12:37"},{"p"=>38, "q"=>"4", "t"=>"12:45"},{"p"=>38, "q"=>"4", "t"=>"12:52"},{"p"=>28, "q"=>"4", "t"=>"13:00"},{"p"=>28, "q"=>"4", "t"=>"13:07"},{"p"=>28, "q"=>"4", "t"=>"13:15"},{"p"=>28, "q"=>"4", "t"=>"13:22"},{"p"=>28, "q"=>"4", "t"=>"13:30"},{"p"=>28, "q"=>"4", "t"=>"13:37"},{"p"=>28, "q"=>"4", "t"=>"13:45"},{"p"=>28, "q"=>"4", "t"=>"13:52"},{"p"=>28, "q"=>"4", "t"=>"14:00"},{"p"=>28, "q"=>"4", "t"=>"14:07"},{"p"=>28, "q"=>"4", "t"=>"14:15"},{"p"=>28, "q"=>"4", "t"=>"14:22"},{"p"=>28, "q"=>"4", "t"=>"14:30"},{"p"=>28, "q"=>"4", "t"=>"14:37"},{"p"=>28, "q"=>"4", "t"=>"14:45"},{"p"=>28, "q"=>"4", "t"=>"14:52"},{"p"=>22, "q"=>"4", "t"=>"15:00"},{"p"=>22, "q"=>"4", "t"=>"15:07"},{"p"=>22, "q"=>"4", "t"=>"15:15"},{"p"=>22, "q"=>"4", "t"=>"15:22"},{"p"=>22, "q"=>"4", "t"=>"15:30"},{"p"=>22,
    # "q"=>"4", "t"=>"15:37"},{"p"=>22, "q"=>"4", "t"=>"15:45"},{"p"=>22, "q"=>"4", "t"=>"15:52"},{"p"=>22, "q"=>"4", "t"=>"16:00"},{"p"=>22, "q"=>"4", "t"=>"16:07"},{"p"=>22, "q"=>"4", "t"=>"16:15"},{"p"=>22, "q"=>"4", "t"=>"16:22"},{"p"=>22, "q"=>"4", "t"=>"16:30"},{"p"=>22, "q"=>"4", "t"=>"16:37"},{"p"=>22, "q"=>"4", "t"=>"16:45"},{"p"=>22, "q"=>"4", "t"=>"16:52"},{"p"=>22, "q"=>"4", "t"=>"17:00"},{"p"=>22, "q"=>"4", "t"=>"17:07"},{"p"=>22, "q"=>"4", "t"=>"17:15"},{"p"=>22, "q"=>"4", "t"=>"17:22"},{"p"=>22, "q"=>"4", "t"=>"17:30"},{"p"=>22, "q"=>"4", "t"=>"17:37"},{"p"=>28, "q"=>"4", "t"=>"17:45"},{"p"=>22, "q"=>"4", "t"=>"17:52"}],"2012-11-23"=>[{"p"=>38, "q"=>"4", "t"=>"06:00"},{"p"=>38, "q"=>"4", "t"=>"06:07"},{"p"=>38, "q"=>"4", "t"=>"06:15"},{"p"=>38, "q"=>"4", "t"=>"06:22"},{"p"=>38, "q"=>"4", "t"=>"06:30"},{"p"=>38, "q"=>"4", "t"=>"06:37"},{"p"=>38, "q"=>"4", "t"=>"06:45"},{"p"=>38, "q"=>"4", "t"=>"06:52"},{"p"=>38, "q"=>"4", "t"=>"07:00"},{"p"=>38, "q"=>"4", "t"=>"07:07"},{"p"=>38, "q"=>"4", "t"=>"07:15"},{"p"=>38, "q"=>"4", "t"=>"07:22"},{"p"=>38, "q"=>"4", "t"=>"07:30"},{"p"=>38, "q"=>"4", "t"=>"07:37"},{"p"=>38, "q"=>"4", "t"=>"07:45"},{"p"=>38, "q"=>"4", "t"=>"07:52"},{"p"=>38, "q"=>"4", "t"=>"08:00"},{"p"=>38, "q"=>"4", "t"=>"08:07"},{"p"=>38, "q"=>"4", "t"=>"08:15"},{"p"=>38, "q"=>"4", "t"=>"08:22"},{"p"=>38, "q"=>"4", "t"=>"08:30"},{"p"=>38, "q"=>"4", "t"=>"08:37"},{"p"=>38, "q"=>"4", "t"=>"08:45"},{"p"=>38, "q"=>"4", "t"=>"08:52"},{"p"=>38, "q"=>"4", "t"=>"09:00"},{"p"=>38, "q"=>"4", "t"=>"09:07"},{"p"=>38, "q"=>"4", "t"=>"09:15"},{"p"=>38, "q"=>"4", "t"=>"09:22"},{"p"=>38, "q"=>"4", "t"=>"09:30"},{"p"=>38, "q"=>"4", "t"=>"09:37"},{"p"=>38, "q"=>"4", "t"=>"09:45"},{"p"=>38, "q"=>"4", "t"=>"09:52"},{"p"=>38, "q"=>"4", "t"=>"10:00"},{"p"=>38, "q"=>"4", "t"=>"10:07"},{"p"=>38, "q"=>"4", "t"=>"10:15"},{"p"=>38, "q"=>"4", "t"=>"10:22"},{"p"=>38, "q"=>"4", "t"=>"10:30"},{"p"=>38, "q"=>"4", "t"=>"10:37"},{"p"=>38, "q"=>"4", "t"=>"10:45"},{"p"=>38, "q"=>"4", "t"=>"10:52"},{"p"=>38, "q"=>"4", "t"=>"11:00"},{"p"=>38, "q"=>"4", "t"=>"11:07"},{"p"=>38, "q"=>"4", "t"=>"11:15"},{"p"=>38, "q"=>"4", "t"=>"11:22"},{"p"=>38, "q"=>"4", "t"=>"11:30"},{"p"=>38, "q"=>"4", "t"=>"11:37"},{"p"=>38, "q"=>"4", "t"=>"11:45"},{"p"=>38, "q"=>"4", "t"=>"11:52"},{"p"=>38, "q"=>"4", "t"=>"12:00"},{"p"=>38, "q"=>"4", "t"=>"12:07"},{"p"=>38, "q"=>"4", "t"=>"12:15"},{"p"=>38, "q"=>"4", "t"=>"12:22"},{"p"=>38, "q"=>"4", "t"=>"12:30"},{"p"=>38, "q"=>"4", "t"=>"12:37"},{"p"=>38, "q"=>"4", "t"=>"12:45"},{"p"=>38, "q"=>"4", "t"=>"12:52"},{"p"=>28, "q"=>"4", "t"=>"13:00"},{"p"=>28, "q"=>"4", "t"=>"13:07"},{"p"=>28, "q"=>"4", "t"=>"13:15"},{"p"=>28, "q"=>"4", "t"=>"13:22"},{"p"=>28, "q"=>"4", "t"=>"13:30"},{"p"=>28, "q"=>"4", "t"=>"13:37"},{"p"=>28, "q"=>"4", "t"=>"13:45"},{"p"=>28, "q"=>"4", "t"=>"13:52"},{"p"=>28, "q"=>"4", "t"=>"14:00"},{"p"=>28, "q"=>"4", "t"=>"14:07"},{"p"=>28, "q"=>"4", "t"=>"14:15"},{"p"=>28, "q"=>"4", "t"=>"14:22"},{"p"=>28, "q"=>"4", "t"=>"14:30"},{"p"=>28, "q"=>"4", "t"=>"14:37"},{"p"=>28, "q"=>"4", "t"=>"14:45"},{"p"=>28, "q"=>"4", "t"=>"14:52"},{"p"=>22, "q"=>"4", "t"=>"15:00"},{"p"=>22, "q"=>"4", "t"=>"15:07"},{"p"=>22, "q"=>"4", "t"=>"15:15"},{"p"=>22, "q"=>"4", "t"=>"15:22"},{"p"=>22, "q"=>"4", "t"=>"15:30"},{"p"=>22, "q"=>"4", "t"=>"15:37"},{"p"=>28, "q"=>"4", "t"=>"15:45"},{"p"=>22, "q"=>"4", "t"=>"15:52"},{"p"=>22, "q"=>"4", "t"=>"16:00"},{"p"=>22, "q"=>"4", "t"=>"16:07"},{"p"=>22, "q"=>"4", "t"=>"16:15"},{"p"=>22, "q"=>"4", "t"=>"16:22"},{"p"=>22, "q"=>"4", "t"=>"16:30"},{"p"=>22, "q"=>"4", "t"=>"16:37"},{"p"=>28, "q"=>"4", "t"=>"16:45"},{"p"=>22, "q"=>"4", "t"=>"16:52"},{"p"=>22, "q"=>"4", "t"=>"17:00"},{"p"=>22, "q"=>"4", "t"=>"17:07"},{"p"=>22, "q"=>"4", "t"=>"17:15"},{"p"=>22, "q"=>"4", "t"=>"17:22"},{"p"=>22, "q"=>"4", "t"=>"17:30"},{"p"=>22, "q"=>"4", "t"=>"17:37"},{"p"=>28, "q"=>"4", "t"=>"17:45"},{"p"=>22, "q"=>"4", "t"=>"17:52"}]}
  end  
    
  
  ####################################
  

  # Post send_object
  def post_response(post_data)
    #respond_to do |format|
    #  format.json { render :json => post_data }
    #end
    render :json => post_data.to_json 
    return post_data
  end

  ## User login form ##
  def user_sign_in
    request_user = params[:email]
    request_uname = params[:fName]
    create_user(request_user, request_uname)
    post_response("User successfully created")
  end


  def decodeDeviceInfo(info)
    if !info.nil?
      info = info.split(',')
      tmpArr = Array.new
      info.each do |tmp|
        reg = /([A-Za-z0-9.]+)/
        op = reg.match(tmp)
        if !op.nil?
          tmpArr << op[1]
        end
      end
      puts "Decoding device info..."
      puts tmpArr
      return tmpArr
    end
  end


  ## User create function ##
  def create_user(username, uname, lname, device_info, app_ver)
    puts "Inside create_user"
    if User.find_by_email(username).blank?
      create = User.new
      create.email = username
      create.f_name = uname
      create.l_name = lname
      res = decodeDeviceInfo(device_info)
      if !res.nil?
        create.device_name = res[1]
        create.os_version = res[2]
      end
      create.app_version = app_ver
      if create.save
        user = User.find_by_email(username)
        puts "User saved -- #{username} -- #{user.id}"
        return user.id 
      else
        puts "Error in creating user"
        post_response(create.errors)
      end
    else
      puts "User already exists"
      post_response("User already exists")
    end
  end


  ## Reservation create function ##
  def create_reservation(user_email, uname, lname, date, tee_time_slot, golfers, course, device_info, app_ver)
    if user_email.blank?
      puts "No Username received"
      return "Unknown_user"
    else
      puts "Find user by email"
      puts user_email
      user = User.find_by_email(user_email)
      if user.blank?
        puts "Cannot find user -- Creating User"
        uid = create_user(user_email, uname, lname, device_info, app_ver)
        puts "User id:"
        puts uid
      else
        puts "Found User"
        puts "User id:"
        uid = user.id
        puts uid
        puts date
      end
    end

    if !uid.blank? && !tee_time_slot.blank? && !golfers.blank?
      @saved_tee_slot = []
      create = Reservation.new
      create.user_id=uid
      create.date=date
      create.time=tee_time_slot
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
    if Reservation.find_by_date(date, :conditions => {:time => tee_slot}).nil?
      puts "--- Requested Tee slot #{tee_slot} is free for date #{date} ---"
      return "success"
    else
      if Reservation.find_all_by_date(date, :conditions => {:time => tee_slot}).count<2
        record = Reservation.find_by_date(date, :conditions => {:time => tee_slot})
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
      if !@tee_slots_booked_for_date.has_key?(record.time)
        @tee_slots_booked_for_date[record.time] = record.golfers
      else
        @tee_slots_booked_for_date[record.time] = @tee_slots_booked_for_date[record.time] + record.golfers
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
    @tee_slots_for_cancel  = []

    puts "Info for deletion email #{email} date #{date} and tee slot #{tee_slot}"
    if !Reservation.find_all_by_date(date, :conditions => {:time => tee_slot}).nil?
      @tee_slots_for_cancel << Reservation.find_by_date(date, :conditions => {:time => tee_slot})
      @tee_slots_for_cancel[0].destroy
    else
      puts "Cannot find reservation to delete"
    end
  end

end
