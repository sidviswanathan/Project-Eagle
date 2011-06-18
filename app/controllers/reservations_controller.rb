class ReservationsController < ApplicationController

$tee_slots = TEE_TIME_SLOTS_DEEP_CLIFF
$course_id = 1

  def book_reservation
    @available_tee_slots = $tee_slots
    @request_params = params
    puts params
    check_reservations(@request_params)
  end


  def check_reservations(request_params)
    @reservation_request = request_params
    puts "Inside make_reservations"

    def initialize(request_user=nil, request_uname=nil, request_date=nil, request_tee_slot=nil, request_golfers=nil, request_cause=nil)
      set_instance_variables(binding, *local_variables)
    end

    request_user = params[:email]
    request_uname = params[:fName]
    request_date = params[:date]
    request_tee_slot = params[:tee_slot]
    request_golfers = params[:golfers]
    request_cause = params[:cause]
    course_id = $course_id
    tee_time_slots = nil

    puts "--- Printing Details of User request ---"
    puts request_user
    puts request_uname
    puts request_date
    puts request_tee_slot
    puts request_golfers
    puts request_cause
    puts "----------------------------------------"

    case request_cause
      when '1'
      ## Requesting for tee slot for given date
        puts "--- Show slots for date #{request_date} ---"
        puts request_cause
        tee_time_slots = show_available_tee_slots_for_date(request_date, course_id)
      when '2'
      ## Requesting for tee slot for given date and hour
        puts "--- Show slots for hour #{request_tee_slot} and date #{request_date} ---"
        tee_time_slots = show_available_tee_slots_for_hour(request_date, request_tee_slot, course_id)
      when '3'
      ## Verifying user and making a reservation
        puts "--- Book Reservation ---"
        check_res_result = check_for_reservation(request_date, request_tee_slot, course_id)
        if check_res_result == "success"
          puts "Creating Reservation"
          create_res = create_reservation(request_user, request_uname, request_date, request_tee_slot, request_golfers, course_id)
          if create_res == "Unknown_user"
            tee_time_slots = "Unknown_user"
          else
            ## Returning same tee slot as requested by user when reservation has been done successfully
            tee_time_slots = create_res
          end
        else
          puts "Slot already reserved"
          tee_time_slots = show_available_tee_slots_for_hour(request_date, request_tee_slot, course_id)
        end
      else
      ## Else Case is case 1
      ## Requesting for tee slot for given date
        puts "--- Show slots for date #{request_date} ---"
        puts request_cause
        tee_time_slots = show_available_tee_slots_for_date(request_date, course_id)
    end

    if !tee_time_slots.blank?
      puts "--- Sending Post response ---"
      puts tee_time_slots
      post_response(tee_time_slots)
    end
  end


  def create_user(username, name)
    puts "Inside create_user"
    create = User.new
    create.email=username 
    create.f_name=name
    create.save
    user = User.find_by_email(username)

    puts "User saved -- #{user}"
    return user.id
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


  ## Private Methods ##
  private

  def set_instance_variables(binding, *variables)
    variables.each do |var|
      instance_variable_set("@#{var}", eval(var, binding))
    end
  end


end
