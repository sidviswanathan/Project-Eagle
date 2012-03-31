require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'chronic'
require 'twiliolib'
require 'twilio-ruby'
require 'pp'

class TextController < ApplicationController
  skip_before_filter :verify_authenticity_token
  T_SID = 'ACc6377a248c5300434e40041d2bd1b9c3'
  T_TOKEN = '8fcabbf06e89b828c7d5b59fb583e38a'
  def recieve
    course = Course.find(params[:course_id].to_s)
    phone = params[:From].sub("+1","")
    body = params[:Body].downcase
    if body.length == 1
      @client = Twilio::REST::Client.new T_SID, T_TOKEN
      d = DataStore.find_by_name("sms_"+params[:From])
      if body == '0'
        @client.account.sms.messages.create(
          :from => '+14087035664',
          :to => params[:From],
          :body => "Sorry you weren't able to complete your booking.  Please call us if you'd still like to play golf at Deep Cliff!"
        )
      else
        @client.account.sms.messages.create(
          :from => '+14087035664',
          :to => params[:From],
          :body => "Your tee time has been confirmed, thanks for your business!"
        )
      end
      
      
    elsif body.length > 1
      uname = ""
      user = Customer.find_or_create_by_phone(phone)
      if !user.f_name.nil?
        uname = user.f_name
      end

      booking = parse_booking(body)
      if !booking.nil?
        d = DataStore.find_by_name("sms_"+params[:From])
        if !d.nil?
          cdate = booking[:date].strftime("%Y-%m-%d")
          ctime = booking[:time].strftime("%H:%M")
          d.update_attributes :data => {"course"=>course.id,"text"=>"","date"=>"#{cdate}","time"=>"#{ctime}","golfers"=>"#{booking[:golfers]}"}.to_json
        else
          booking_info = {:name=>"sms_"+params[:From],:data=>{"course"=>course.id,"text"=>"","date"=>"#{cdate}","time"=>"#{ctime}","golfers"=>"#{booking[:golfers]}"}.to_json}
          d = DataStore.create(booking_info)
        end

        clean_date = booking[:date].strftime("%A %B %d")
        clean_time = booking[:time].strftime("%l:%M%p")



        closest,avail = get_slots(course,cdate,ctime)
        if avail.length > 0
          clean_time = Time.parse(closest).strftime("%l:%M%p")
          slot_list = " OR "

          avail.each_with_index do |ss,ii|
            slot_list +=  "#{(ii+2).to_s} for #{Time.parse(ss).strftime('%l:%M%p')}, "
          end
          sms = "#{booking[:golfers]} golfers on #{clean_date} at #{clean_time}?  Reply 1 to confirm, 0 to cancel#{slot_list}"


        else
          sms = "Sorry, there don't seem to be any available slots for around #{clean_time} on #{clean_date}.  Please try for a different date/time.  "
        end 


      else
        sms = "Sorry we didn't quite get that!  Text something like 'for 4 golfers on sunday at 10', or call us at 408-703-5664. Thanks!"
      end

      @client = Twilio::REST::Client.new T_SID, T_TOKEN
      @client.account.sms.messages.create(
        :from => '+14087035664',
        :to => params[:From],
        :body => sms
      )
    else
      @client = Twilio::REST::Client.new T_SID, T_TOKEN
      @client.account.sms.messages.create(
        :from => '+14087035664',
        :to => params[:From],
        :body => "Text 14087035664 something like 'Sunday at 3pm for 2 golfers' to book a tee time at Deep Cliff."
      )
    end
    

    render :nothing => true
  end
  
  
  def parse_booking(text)
    
    split = text.split(" ")
    days = ["monday","mon","tuesday","tue","tues","wednesday","wed","thursday","thurs","th","thu","friday","fri","saturday","sat","sunday","sun","today","tomorrow","day after tomorrow"]
    ampm = ["am","pm","a.m.","p.m."]
    date = nil
    golfers = nil
    time = nil
    split.each_with_index do |s,i|
      if days.include? s
        date = Chronic.parse(s)
      elsif s == 'on'
        date = Chronic.parse(split[i+1])
      elsif s == 'at'
        time = Time.parse(split[i+1])
      elsif ampm.include? s
        time = Time.parse(split[i-1]+s)
      elsif s == 'golfers'
        g = split[i-1].to_i
        if [2,3,4].include? g
          golfers = g
        end
        
      elsif s == 'for'
        g = split[i+1].to_i
        if [2,3,4].include? g
          golfers = g
        end
      end
    end
    if date.nil?
      date = Date.today
      
    end
    
    if time.nil?
      time = Time.now + (60*30)
      time = time.strftime("%l:%p")
    end
    
    if golfers.nil?
      golfers = 2
    end
    
    
    return {:golfers=>golfers,:date=>date,:time=>time}
  end
  
  
  
  def get_slots(course,date,time)

    dates = JSON.parse(course.available_times)
    @times = dates[date]["day"]
    ret = []
    closest = nil
    avail = []
    @times.each_with_index do |t, i|
      if t['t'] > time
        closest = t['t']
        avail = []
        @times[i-2,5].each do |tt|
          avail.push(tt['t'])
        end
        break
      end
    end

    return closest,avail
      
  end
  
end






















