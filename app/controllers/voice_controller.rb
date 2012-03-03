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
      greeting = 'Welcome to Deep Cliff Golf Course.  To book a Tee Time, press 1.  To sign up to recieve exclusive deals, press 2. To speak with the course, press 3'
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
        r.Say " After the Beeep, say something like .. Tuesday at 2 P.M. fohr 3 golfers ", :voice => 'man'
        r.Pause :length => 2
        r.Record :action => "/voice/getdate", :transcribeCallback => '/voice/transcribe_callback', :maxLength => 8, :timeout => 2
      elsif params[:Digits] == "2"
        r.Gather :action => "/voice/deal_signup", :numDigits => 1 do |d|
          d.Say "If you would like to be notified by text message, Press 1 .. by Phone Press 2"
        end
      else
        r.Say "Connecting to Deep Cliff Golf Course ", :voice => 'man'
        r.Dial "4082535357"
      end
    end
    render :text => response.text
  end
  
  def deal_signup
    response = Twilio::TwiML::Response.new do |r|
      r.Say "Thanks for signing up.  In addition to exclusive deals you are now entered in Deep Cliff's weekly Free Tee Time lottery.  Please tell your friends!"
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
    data["golfers"] = "0"
    
    split = data["text"].split(" ")
    
    golfers = "2"
    xdate = nil
    time = "2"
    
    days = ["monday","tuesday","wednesday","thursday","friday","saturday","sunday"]
    nexter = false
    count = 0
    substring = ""
    
    if data["text"].include? "p. m." or data["text"].include? "a. m." or data["text"].include? "am" or data["text"].include? "pm" or data["text"].include? "a.m." or data["text"].include? "p.m."
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

    if golfers.to_i < 5 and golfers.to_i > 1
      data["golfers"] = golfers
    end
    
    
    
    d.data = data.to_json
    d.save
    @client = Twilio::REST::Client.new T_SID, T_TOKEN
    @call = @client.account.calls.get(params[:CallSid])
    if data["day"].nil?
      @call.redirect_to('http://www.presstee.com/voice/date_select')
    elsif data["time"].nil?
      @call.redirect_to('http://www.presstee.com/voice/time_select')
    elsif data["golfers"].to_i == 0
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

    dt = Time.parse(data["date"])
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
            d.Say day.strftime(" %A %B %-d ")
          else
            d.Say day.strftime(" %A ")
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
    now = Time.now
    if now > Time.parse("17:00")
      today += 1
    end
    xdate = [today,today+1,today+2,today+3,today+4,today+5,today+6,today+7][params[:Digits].to_i-1]
    
    redirect = ""
    if data["time"].nil?
      data["temp_date"] = xdate.to_s
      redirect = "time_select"
    elsif data["golfers"] == 0
      data["date"] = Time.parse(xdate.strftime("%Y-%m-%d "+data["time"])).to_s
      redirect = "golfers"
    else
      data["date"] = Time.parse(xdate.strftime("%Y-%m-%d "+data["time"])).to_s
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
    greeting = 'Sorry we didnt quite get the hour you wanted.  Please press the key or keys corresponding the the intended hour between 6 AM and 4 PM.  For example, press 6 for 6 A.M .. .. 11 for 11 AM .. or .. 2 for 2 P.M. '
    response = Twilio::TwiML::Response.new do |r|
      r.Gather :action => "/voice/time_select_callback" do |d|
        d.Say greeting, :voice => 'man'
      end
    end
    render :text => response.text
  end
  
  def time_select_callback
    d = DataStore.find_by_name("call_"+params[:CallSid])
    data = JSON.parse(d.data)
    hours = {"6"=>"6 AM","7"=>"7 AM","8"=>"8 AM","9"=>"9 AM","10"=>"10 AM","11"=>"11 AM","12"=>"12 PM","1"=>"1 PM","2"=>"2 PM","3"=>"3 PM","4"=>"4 PM"}
    if hours.has_key? params[:Digits]
      data["time"] = hours[params[:Digits]]
      redirect = ""

      if data["date"].nil?
        redirect = "date_select"
      elsif data["golfers"].to_i == 0
        data["date"] = Chronic.parse(data["date"]).strftime("%A %B %d "+data["time"])
        redirect = "golfers"
      else
        data["date"] = Chronic.parse(data["date"]).strftime("%A %B %d "+data["time"])
        redirect = "gettime"
      end
      d.data = data.to_json
      d.save
      response = Twilio::TwiML::Response.new do |r|
        r.Redirect "/voice/#{redirect}"
      end
    else
      greeting = 'Try again .. for example,  press 6 for 6 A.M. 1 1 for 11 AM or 2 for 2 P.M. '
      response = Twilio::TwiML::Response.new do |r|
        r.Gather :action => "/voice/time_select_callback" do |d|
          d.Say greeting, :voice => 'man'
        end
      end
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
    elsif data["date"].nil?
      r.Redirect "/voice/date_select"
    else
      response = Twilio::TwiML::Response.new do |r|
        slots = get_slots(data)
        greeting = "Please choose from the following slots for "+data["golfers"]+" golfers on "+ Time.parse(data["date"]).strftime("%A %B %d")
        puts greeting

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
              d.Say " fohr "
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
          r.Say "We couldn't find any slots for #{data['golfers']} on "+data["date"].strftime("%A %B %d ")+data["date"].strftime(" at %l %m %p")
          r.Redirect "/voice/options?Digits=1&sorry=1"
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
  
  def confirm
    
    if params[:Digits] == "1"
      d = DataStore.find_by_name("call_"+params[:CallSid])
      data = JSON.parse(d.data)
      dt = Time.parse(data["date"])
      date = dt.strftime("%Y-%m-%d")
      total = (slot["p"] * data["golfers"].to_i).to_s
      reservation = Reservation.book_tee_time("carlcwheatey@gmail.com", data["course"], data["golfers"], data['slot']["t"], date, total)
      r.Say "Thanks for your business, please note your Reservation number is #{reservation.confirmation_code}"
    elsif params[:Digits] == "2"
      r.Redirect "/voice/options"
    else
      r.Say "Connecting to Deep Cliff Golf Course ", :voice => 'man'
      r.Dial "4082535357"
    end
  end
  
  def book
    if params[:Digits].to_i == 0
      response = Twilio::TwiML::Response.new do |r|
        r.Redirect "/voice/gettime"
      end
    else
      d = DataStore.find_by_name("call_"+params[:CallSid])
      data = JSON.parse(d.data)
      dt = Time.parse(data["date"])
      date = dt.strftime("%Y-%m-%d")
      clean_date = dt.strftime("%A %B %d")
      clean_time = dt.strftime(" at %l %m %p")
      slots = get_slots(data)
      slot = slots[params[:Digits].to_i-1]
      data["slot"] = slot
      d.data = data.to_json
      d.save
      total = (slot["p"] * data["golfers"].to_i).to_s
      #reservation = Reservation.book_tee_time("carlcwheatley@gmail.com", data["course"], data["golfers"], slot["t"], date, total)
      response = Twilio::TwiML::Response.new do |r|
        greeting = "Your total due at course for #{data['golfers']} golfers on #{clean_date} at #{clean_time} is #{total} dollars.  Please confirm by pressing 1, cancel by pressing 2 or press 3 to speak with a Deep Cliff Staff Member"
        #greeting = "Thanks for your business, please note that your total due at course is "+total+" dollars .  If you would like to return to the main menu, press 1.  If you would like to cancel this reservation, press 2.  To speak with Deep Cliff Staff, press 3. "
        r.Gather :action => "/voice/confirm" do |d|
          r.Say greeting, :voice => 'man'
        end
        
      end
    end
      
    
    render :text => response.text
  end

end
