require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'chronic'
require 'twiliolib'
require 'twilio-ruby'
require 'pp'

class VoiceController < ApplicationController
  skip_before_filter :verify_authenticity_token
  T_SID = 'ACc6377a248c5300434e40041d2bd1b9c3'
  T_TOKEN = '8fcabbf06e89b828c7d5b59fb583e38a'
  def recieve
    course = Course.find(params[:course_id].to_s)
    phone = params[:From].sub("+1","")
    user = User.find_or_create_by_phone(phone)
    response = Twilio::TwiML::Response.new do |r|
      d = DataStore.create({:name=>"call_"+params[:CallSid],:data=>{"course"=>course.id,"text"=>"","voice"=>"","golfers"=>"2"}.to_json})
      greeting = 'Welcome to Deep Cliff Golf Course.  To book a Tee Time, press 1.  To speak with the course, press 2'
      r.Gather :action => "/voice/options" do |d|
        d.Say greeting, :voice => 'man'
      end

    end
    render :text => response.text
  end
  
  def options
    response = Twilio::TwiML::Response.new do |r|
      prepend = ""
      if params[:Digits] == "1"
        if params[:sorry].to_i > 0
          prepend = "Sorry, we didn't quite get that .. "
        end
        r.Say "Now say something like .. tuesday at 2pm for 4 golfers ", :voice => 'man'
        r.Record :action => "/voice/getdate", :transcribeCallback => '/voice/transcribe_callback', :maxLength => 8, :timeout => 2
      else
        r.Say "Connecting to Deep Cliff Golf Course ", :voice => 'man'
        r.Dial "4082535357"
      end
    end
    render :text => response.text
  end
  
  def transcribe_callback
    d = DataStore.find_by_name("call_"+params[:CallSid])
    data = JSON.parse(d.data)
    data["text"]  = params[:TranscriptionText].downcase
    data["voice"] = params[:RecordingUrl]
    data["day"] = nil
    data["time"] = nil
    data["date"] = nil
    
    split = data["text"].split(" ")
    
    golfers = "2"
    xdate = nil
    time = "2"
    
    days = ["monday","tuesday","wednesday","thursday","friday","saturday","sunday"]
    nexter = false
    count = 0
    substring = ""
    
    if data["text"].include? "P.M." or data["text"].include? "A.M."
      data["time"] = true
    end
    
    remain = data["text"]
    split.each do |s|
      substring += s+" "
      date = Chronic.parse(substring)
      if !date.nil?
         data["date"] = date.to_s
        remain = data["text"].sub(substring,"")
      end
      if days.include? s
        data["day"] = s
      end
      if s == 'next'
        nexter = true
      end
    end
    left = remain.split(" ")
    
    counter = 0
    left.each do |r|
      golfers = r.to_i
      break if golfers > 1
    end
    
    golfers = golfers.to_s
    
    puts golfers

    
    data["golfers"] = golfers
    
    
    
    d.data = data.to_json
    d.save
    @client = Twilio::REST::Client.new T_SID, T_TOKEN
    @call = @client.account.calls.get(params[:CallSid])
    if data["day"].nil?
      @call.redirect_to('http://www.presstee.com/voice/date_select')
    elsif data["time"].nil?
      @call.redirect_to('http://www.presstee.com/voice/time_select')
    elsif data["golfers"] == 0
      @call.redirect_to('http://www.presstee.com/voice/golfers')
    else
      @call.redirect_to('http://www.presstee.com/voice/gettime')
    end
      
    
    render :nothing => true
  end
  
  def getdate
    d = DataStore.find_by_name("call_"+params[:CallSid])
    data = JSON.parse(d.data)

    response = Twilio::TwiML::Response.new do |r|
      r.Say "Please wait a few seconds while we process your request", :voice => 'man'
      r.Play "http://fozzy42.com/SoundClips/Themes/TV/jeapordy.wav", :loop => 0
    end
    render :text => response.text
    
  end
  
  def get_slots(data)
    course_id    = data["course"]
    dt = Chronic.parse(data["date"])
    time         = dt.strftime("%H:%M")   
    date         = dt.strftime("%Y-%m-%d")
    
    updated_course = Rails.cache.fetch("Updated_Course_"+course_id.to_s) {Course.find(course_id)}
    
    dates = JSON.parse(updated_course.available_times)
    if dates.has_key?(date)
       if dates[date]["hours"].has_key?(time.split(":")[0].to_i.to_s)
         avail   = dates[date]["hours"][time.split(":")[0].to_i.to_s]
       else
         avail   = nil
       end
    else
      avail = nil
    end
    
    return avail
      
  end
  
  def date_select
    greeting = 'Sorry we didnt quite get the date you wanted .. Please select from the following '
    today = Date.today
    now = Time.now
    if now > Time.parse("17:00")
      today += 1
    end
    
    response = Twilio::TwiML::Response.new do |r|
      r.Gather :action => "/voice/date_select_callback" do |d|
        d.Say greeting, :voice => 'man'
        counter = 0
        [today,today+1,today+2,today+3,today+4,today+5,today+6,today+7].each do |day|
          counter += 1
          if counter == 1
            d.Say "Press "
          end
          d.Say counter
          d.Say " fore "
          if counter == 1 or counter == 8
            d.Say today.strftime(" %A %B %-d ")
          else
            d.Say today.strftime(" %A ")
          end
        end
      end
    end
    render :text => response.text
  end
  
  def date_select_callback
    d = DataStore.find_by_name("call_"+params[:CallSid])
    data = JSON.parse(d.data)
    
    today = Date.today
    if now > Time.parse("17:00")
      today += 1
    end
    xdate = [today,today+1,today+2,today+3,today+4,today+5,today+6,today+7][params[:Digits].to_i-1]
    
    redirect = ""
    if data["time"].nil?
      data["temp_date"] = xdate.to_s
      redirect = "time_select"
    elsif data["golfers"] == 0
      data["date"] = Chronic.parse(xdate.strftime("%A %B %d "+data["time"]))
      redirect = "golfers"
    else
      data["date"] = Chronic.parse(xdate.strftime("%A %B %d "+data["time"]))
      redirect = "gettime"
    end
    d.data = data.to_json
    d.save
    response = Twilio::TwiML::Response.new do |r|
      r.Redirect "/voice/#{redirect}"
    end
    render :text => response.text
  end
  
  def time_select
    greeting = 'Sorry we didnt quite get the hour you wanted .. Please select from the following '
    response = Twilio::TwiML::Response.new do |r|
      r.Gather :action => "/voice/time_select_callback" do |d|
        d.Say greeting, :voice => 'man'
        counter = 0
        hours = ["6 A.M.","7 A.M.","8 A.M.","9 A.M.","10 A.M.","11 A.M.","12 P.M.","1 P.M.","2 p.M.","3 P.M.","4 P.M."]
        hours.each do |h|
          counter += 1
          if counter == 1
            d.Say "Press "
          end
          d.Say counter
          d.Say " fore "
          d.Say h
        end
      end
    end
    render :text => response.text
  end
  
  def time_select_callback
    d = DataStore.find_by_name("call_"+params[:CallSid])
    data = JSON.parse(d.data)
    hours = ["6 A.M.","7 A.M.","8 A.M.","9 A.M.","10 A.M.","11 A.M.","12 P.M.","1 P.M.","2 p.M.","3 P.M.","4 P.M."]
    data["time"] = hours[params[:Digits].to_i-1]

    redirect = ""

    if data["date"].nil?
      redirect = "date_select"
    elsif data["golfers"].to_i == 0
      data["date"] = Chronic.parse(data["date"].strftime("%A %B %d "+data["time"]))
      redirect = "golfers"
    else
      data["date"] = Chronic.parse(data["date"].strftime("%A %B %d "+data["time"]))
      redirect = "gettime"
    end
    d.data = data.to_json
    d.save
    response = Twilio::TwiML::Response.new do |r|
      r.Redirect "/voice/#{redirect}"
    end
    render :text => response.text
  end
  
  
  
  def gettime
    d = DataStore.find_by_name("call_"+params[:CallSid])
    data = JSON.parse(d.data)   
    if params[:add] == "golfers"
      data["golfers"] = params[:Digits]
    end
    
    if data["golfers"].to_i == 0
      response = Twilio::TwiML::Response.new do |r|
        r.Redirect "/voice/golfers"
      end
    elsif data[""]
    else
      response = Twilio::TwiML::Response.new do |r|
        begin
          slots = get_slots(data)
          greeting = "Please choose from the following slots for "+data["golfers"]+" golfers on "+ Chronic.parse(data["date"]).strftime("%A %B %d")

          if !slots.nil?
            r.Gather :action => "/voice/book", :timeout => 15 do |d|
              counter = 0
              d.Say greeting
              d.Pause :length => 3
              slots.each do |slot|
                counter += 1
                if counter == 1
                  d.Say "Press "
                end
                d.Say counter.to_s
                d.Say " fore "
                d.Pause :length => 1
                dt = Chronic.parse(slot["t"])
                t = dt.strftime("%M")
                if t[0,1] == "0"
                  if t[1,1] == "0"
                    t = " "
                  else
                    t = "Oh "+t[1,1]
                  end
                end
                d.Say " "+dt.strftime("%l")+" "+t+" "+dt.strftime("%p")
                d.Pause :length => 2
              end
              d.Say " If you would like to repeat this menu, press 0 now"
            end
          else
            r.Redirect "/voice/options?Digits=1&sorry=1"
          end
        rescue
          r.Say "Connecting to Deep Cliff Golf Course ", :voice => 'man'
          r.Dial "4082535357"
        end


      end
    end
    
    render :text => response.text
  end
  
  def golfers
    response = Twilio::TwiML::Response.new do |r|
      r.Say "Sorry we didn't quite get the number of golfers in your party.  Please press a number from 2-4 to continue"
      r.Gather :action =>"/voice/gettime?add=golfers"
    end
    render :text => response.text
  end
  
  def book
    if params[:Digits].to_i == 0
      response = Twilio::TwiML::Response.new do |r|
        r.Redirect "/voice/gettime"
      end
    else
      d = DataStore.find_by_name("call_"+params[:CallSid])
      data = JSON.parse(d.data)
      dt = Chronic.parse(data["date"])
      date = dt.strftime("%Y-%m-%d")
      slots = get_slots(data)
      slot = slots[params[:Digits].to_i-1]
      total = (slot["p"] * data["golfers"].to_i).to_s
      reservation = Reservation.book_tee_time("carlcwheatley@gmail.com", data["course"], data["golfers"], slot["t"], date, total)
      response = Twilio::TwiML::Response.new do |r|
        greeting = "Thanks for your business, your cost is "+total+" dollars due at course"
        r.Say greeting, :voice => 'man'
      end
    end
      
    
    render :text => response.text
  end

end
