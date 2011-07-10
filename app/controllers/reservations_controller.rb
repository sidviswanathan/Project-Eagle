require 'pp'
require 'logger'
require 'lib/twilio/twilio.rb'

include Twilio

class ReservationsController < ApplicationController

  protect_from_forgery :except => [:initiate_twilio_call,:place_automated_call]   

  $tee_slots = TEE_TIME_SLOTS_DEEP_CLIFF
  $course_id = 1

  def book_reservation
    @available_tee_slots = $tee_slots
    status = check_reservations(params)
    initiate_twilio_call(params) if status != nil
  end

  def check_reservations(request_params)
    @reservation_request = request_params
    puts "Inside make_reservations"

    def initialize(request_user=nil, request_uname=nil, request_date=nil, request_tee_slot=nil, request_golfers=nil, request_cause=nil)
      set_instance_variables(binding, *local_variables)
    end

    request_user = params[:email]
    request_uname = params[:fName]
    request_lname = params[:lname]
    request_date = params[:date]
    request_tee_slot = params[:tee_slot]
    request_golfers = params[:golfers]
    request_cause = params[:cause]
    course_id = $course_id
    tee_time_slots = nil

    puts "--- Printing Details of User request ---"
    puts request_user
    puts request_uname
    puts request_lname
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
        check_res_result = check_for_reservation(request_date, request_tee_slot, request_golfers, course_id)
        if check_res_result == "success"
          puts "Creating Reservation"
          create_res = create_reservation(request_user, request_uname, request_date, request_tee_slot, request_golfers, course_id)
          if create_res == "Unknown_user"
            tee_time_slots = "Unknown_user"
          else
            ## Returning same tee slot as requested by user when reservation has been done successfully
            tee_time_slots = create_res
            ## Make response for twilio
            twilio_data = {'email' => request_user, 'fname' => request_uname, 'lname' => request_lname, 'date' => request_date, 'tee_slot' => request_tee_slot, 'golfers' => request_golfers}
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
      return twilio_data
    end
  end
  
  def initiate_twilio_call(params)
    puts "INSIDE INITIATE TWILIO CALL"
    make_twilio_call(params)
  end  

  def place_automated_call
    @r = Twilio::Response.new
    @r.append(Twilio::Say.new(params["SAY"], :voice => "man", :loop => "1"))
    puts @r.respond
  end

  ## Private Methods ##
  private

  def set_instance_variables(binding, *variables)
    variables.each do |var|
      instance_variable_set("@#{var}", eval(var, binding))
    end
  end


end
