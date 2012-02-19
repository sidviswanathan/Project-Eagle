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
    #initiate_twilio_call(params) if status != nil
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
    request_tee_slot = params[:time]
    request_golfers = params[:golfers]
    request_cause = params[:cause]
    request_device_info = params[:deviceInfo]
    request_app_version = params[:appVersion]
    course_id = $course_id
    tee_time_slots = nil

    puts "---- Printing Details of User request ----"
    puts "User #{request_user}"
    puts "First name #{request_uname}"
    puts "Last name #{request_lname}"
    puts "Date #{request_date}"
    puts "Tee slot #{request_tee_slot}"
    puts "Golfers #{request_golfers}"
    puts "Cause value #{request_cause}"
    puts "Device info #{request_device_info}"
    puts "App version #{request_app_version}"
    puts "------------------------------------------"


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
          create_res = create_reservation(request_user, request_uname, request_lname, request_date, request_tee_slot, request_golfers, course_id, request_device_info, request_app_version)
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
  
  def test_data
    r = Reservation.all(:conditions=>["course_id='2'"])
    data = {"early"=>[],"cursor"=>0}
    r.each do |rr|
      book_dt = rr.created_at.in_time_zone("Pacific Time (US & Canada)")
      teetime = rr.date.strftime("%Y-%m-%d")+" "+rr.time
      tt_dt = DateTime.strptime(teetime,"%Y-%m-%d %H:%M")
      data["early"].push({:dt=>book_dt-tt_dt,:book=>book_dt,:teetime=>tt_dt)
      data["cursor"] = rr.id.to_s
    end
    render :json => data.to_json
    
    
  end
  
  def update_data
    @course_id = params[:course_id]
    
    d = Dump.find(201302)
    if d.nil?
      d = Dump.create(:data=>{"cursor"=>"0","early"=>[]}.to_json)
      r = Reservation.all(:conditions=>["course_id='#{@course_id}'"])
      data = JSON.parse(d.data)
    else
      data = JSON.parse(d.data)
      r = Reservation.all(:conditions=>["id > #{data['cursor']} AND course_id='#{@course_id}'"])
    end
    r.each do |rr|
      book_dt = rr.created_at.in_time_zone("Pacific Time (US & Canada)")
      tt_dt = DateTime.strptime(rr.date+" "+rr.time,"%Y-%m-%d %H:%M")
      data["early"].push(book_dt-tt_dt)
      data["cursor"] = rr.id.to_s
    end
    #d.data = data.to_json
    #d.save
    render :json => data.to_json
    
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
