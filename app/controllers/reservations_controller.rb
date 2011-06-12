class ReservationsController < ApplicationController

@@tee_slots = TEE_TIME_SLOTS_DEEP_CLIFF
@@unknown_user = "Unknown"
@@date = Date.today
@@course_id = 1

  def book_reservation
    @available_tee_slots = @@tee_slots
    @request_params = params
    puts params
    check_reservations(@request_params)
  end

  def check_reservations(request_params)

    @reservation_request = request_params
    puts "Inside check_reservation"

    def initialize(request_user=nil, request_uname=nil, request_date=nil, request_tee_slot=nil, request_golfers=nil)
      set_instance_variables(binding, *local_variables)
    end

    request_user = params[:email]
    request_uname = params[:fName]
    request_date = params[:date]
    request_tee_slot = params[:tee_slot]
    request_golfers = params[:golfers]

    puts "### Printing Details of User request ###"
    puts request_user
    puts request_uname
    puts request_date
    puts request_tee_slot
    puts request_golfers

    if request_user.blank?
      puts "No Username received"
      #send_object(@@unknown_user)
      #break
    else
      puts "Find user by email"
      puts request_user
      user = User.find_by_email(request_user)

      if user.blank?
        puts "Cannot find user -- Creating User"
        user_id = create_user(request_user, request_uname)
        puts user_id
      else
        puts "Found User"
        user_id=user.id
        puts user_id
      end
      if Reservation.find_by_date(request_date, :conditions => {:tee_slot => request_tee_slot}).nil?
        puts "Requested Tee slot not found for date -- Creating Tee Slot"
        create_reservation(user_id, request_date, request_tee_slot, request_golfers, @@course_id)
      else
        puts "Tee Slot not available"
        puts "Checking for free Tee Slots"
        @tee_slots_for_date = Reservation.find_all_by_date(request_date)

        @tee_slots_booked_for_date = []
        @tee_slots_for_date.each do |record|
          @tee_slots_booked_for_date << record.tee_slot
        end
        puts "-- All tee slots booked for given date --"
        puts @tee_slots_booked_for_date

        free_tee_slots = show_available_tee_slots_for_date(@tee_slots_booked_for_date)
        puts "----- These are the free slots for request date ----"
        puts free_tee_slots
        #send_object(free_tee_slots)
      end
    end
  end

  def create_user(username, name)
    puts "Inside create_user"
    create = User.new
    create.email=username 
    create.f_name=name
    create.save
    puts "User saved"
    user = User.find_by_email(username)
    return user.id
  end

  def create_reservation(id, date, tee_slot, golfers, course)
    create = Reservation.new
    create.user_id=id
    create.date=date
    create.tee_slot=tee_slot
    create.golfers=golfers
    create.course_id=course
    create.save
    puts "Reservation recorded"
    puts "----- Congratulations you have successfully reserved a tee slot -----"
    puts "Please wait for confirmation"
  end

  def show_available_tee_slots_for_date(tee_slots)
    puts "--- Calculating free tee slots for give date ---"
    @booked_tee_slots = tee_slots
    @all_tee_slots = @@tee_slots
    free_slots_for_date = @all_tee_slots - @booked_tee_slots
    return free_slots_for_date
    #send_object(free_slots_for_date)
  end


  ## Private Methods ##
  private

  def set_instance_variables(binding, *variables)
    variables.each do |var|
      instance_variable_set("@#{var}", eval(var, binding))
    end
  end

end
