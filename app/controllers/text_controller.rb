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
        ctime = booking[:time].strftime("%l:%p")
        d.update_attributes :data => {"course"=>course.id,"text"=>"","date"=>"#{cdate}","time"=>"#{ctime}","golfers"=>"#{booking[:golfers]}"}.to_json
      else
        booking_info = {:name=>"sms_"+params[:From],:data=>{"course"=>course.id,"text"=>"","date"=>"#{cdate}","time"=>"#{ctime}","golfers"=>"#{booking[:golfers]}"}.to_json}
        d = DataStore.create(booking_info)
      end
      
      clean_date = booking[:date].strftime("%A %B %d")
      clean_time = booking[:time].strftime("%l:%M%p")
      
      slots = get_slots(course,cdate,ctime)      
      
      sms = "Book tee time for #{booking[:golfers]} golfers on #{clean_date} at #{slots[3]}?  Reply 1 to confirm, 2 to cancel."
    else
      sms = "Sorry we didn't quite get that!  Text something like 'for 4 golfers on sunday at 10', or call us at 408-703-5664. Thanks!"
    end

    @client = Twilio::REST::Client.new T_SID, T_TOKEN
    @client.account.sms.messages.create(
      :from => '+14087035664',
      :to => params[:From],
      :body => sms
    )

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
    @times.each_with_index do |t, i|
      if t['t'] > time
        avail =  @times[i-2,5]
      end
    end

    return avail
      
  end
  
end






















