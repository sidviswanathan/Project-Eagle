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
    dd = DataStore.find_by_name("sms_recheck_"+params[:From])
    uname = ""
    user = Customer.find_or_create_by_phone(phone)
    if !user.f_name.nil?
      uname = user.f_name
    end
    if body.length == 1 and dd.nil?
      @client = Twilio::REST::Client.new T_SID, T_TOKEN
      d = DataStore.find_by_name("sms_"+params[:From])
      if body == '0'
        @client.account.sms.messages.create(
          :from => '+14087035664',
          :to => params[:From],
          :body => "Sorry you had to cancel your booking attempt.  Please call us if you'd still like to play golf at Deep Cliff!"
        )
      else
        d = DataStore.find_by_name("sms_"+params[:From])
        data = JSON.parse(d.data)
        if params[:Body] == "1"
          time = data["time"]
          t = Time.parse(time)
        else
          time = data["avail"][params[:Body].to_i-2]
          time = Time.parse(time).strftime("%l:%M%p")
          t = Time.parse(time)
        end


        total = (data["avail_full"][params[:Body].to_i-2]["p"] * data["golfers"].to_i).to_s

        phone = params[:From].sub("+1","")
        user = Customer.find_by_phone(phone)
        reservation,res,message = Reservation.book_tee_time(user, course.id.to_s, data["golfers"], t.strftime("%H:%M"), Date.parse(data["date"]).strftime("%Y-%m-%d"), total)
        
        if !reservation.nil?
          @client.account.sms.messages.create(
            :from => '+14087035664',
            :to => params[:From],
            :body => "Your tee time for #{data['golfers']} golfers on #{data['date']} at #{time} has been confirmed (#{reservation.confirmation_code})! Your total due at course is $#{total}, thanks for your business."
          )
        else
          @client.account.sms.messages.create(
            :from => '+14087035664',
            :to => params[:From],
            :body => "Sorry, #{message}.  Or you can call us at 408-703-5664.  Thanks!"
          )
        end
        
        

      end
      
      
    elsif body.length > 1 or !dd.nil?

      
      
      if !dd.nil?
        puts dd.data
        booking = JSON.parse(dd.data)
        booking = {:golfers=>booking['golfers'],:date=>booking['date'],:time=>booking["time"],:recheck=>booking["recheck"]}
        if booking[:recheck][0] == 'date'
          booking[:date] = Chronic.parse(body)
          booking[:time] = Time.parse(booking[:time])
        elsif booking[:recheck][0] == 'time'
          booking[:time] = Time.parse(body)
          booking[:date] = Date.parse(booking[:date])
        elsif booking[:recheck][0] == 'golfers'
          booking[:time] = Time.parse(booking[:time])
          booking[:date] = Date.parse(booking[:date])
          booking[:golfers] = body.to_i.to_s
        end
        booking[:recheck] = []
        dd.destroy
        
      else
        booking = parse_booking(body)
      end
      recheck = booking[:recheck]
      
      if !booking.nil? and recheck.length == 0

        clean_date = booking[:date].strftime("%A %B %d")
        clean_time = booking[:time].strftime("%l:%M%p")
        cdate = booking[:date].strftime("%Y-%m-%d")
        ctime = booking[:time].strftime("%H:%M")

        closest,avail,avail_full = get_slots(course,cdate,ctime)
        if avail.length > 0
          clean_time = Time.parse(closest).strftime("%l:%M%p")
          slot_list = " OR "

          avail.each_with_index do |ss,ii|
            slot_list +=  "(#{(ii+2).to_s})#{Time.parse(ss).strftime('%l:%M%p')}\n"
          end
          
          d = DataStore.find_by_name("sms_"+params[:From])
          if !d.nil?
            
            d.update_attributes :data => {"course"=>course.id,"text"=>"","date"=>"#{cdate}","time"=>"#{closest}","clean_time"=>clean_time,"avail_full"=>avail_full,"avail"=>avail,"golfers"=>"#{booking[:golfers]}"}.to_json
          else
            booking_info = {:name=>"sms_"+params[:From],:data=>{"course"=>course.id,"text"=>"","date"=>"#{cdate}","time"=>"#{closest}","avail"=>avail,"avail_full"=>avail_full,"golfers"=>"#{booking[:golfers]}"}.to_json}
            d = DataStore.create(booking_info)
          end
          
          
          sms = "#{booking[:golfers]} golfers on #{clean_date} at #{clean_time}? Press (1)confirm, (2)cancel #{slot_list}"


        else
          sms = "Sorry, there don't seem to be any available slots for around #{clean_time} on #{clean_date}.  Please try for a different date/time.  "
        end 
        
      elsif recheck.length == 1
        dd = DataStore.create({:name=>"sms_recheck_"+params[:From],:data=>booking.to_json})
        if recheck[0] == 'golfers'
          sms = "Please reply with the number of golfers in your party between 2-4, for example '4' or '4 golfers'"
        elsif recheck[0] == 'date'
          sms = "Please reply with the day you want to play.  For example 'tomorrow' or 'tuesday' "
        else
          sms = "Please reply with the time you'd like to start.  For example '10am' or '3'"
        end

        

      else
        sms = "Welcome to Deep Cliff Golf Course. To book a tee time, text something like 'for 4 golfers on sunday at 10', or call us at 408-703-5664. Thanks!"
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
        :body => "Welcome to Deep Cliff Golf Course.  To book a tee time, text something like 'Sunday at 3pm for 2 golfers', or call us at 408-703-5664."
      )
    end
    

    render :nothing => true
  end
  

  def parse_booking(text)
    text = text.gsub(","," ")
    text = text.gsub(".","")
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
      elsif s == 'at' or s == 'around'
        xt = split[i+1].to_i

        if xt < 6 or xt == 12
          xt = xt.to_s+"pm"
        else
          xt = xt.to_s+"am"
        end
          
        
        time = Time.parse(xt)
      elsif s.include? ":"
        time = Time.parse(s)
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
    
    recheck = []
    if date.nil?
      date = Date.today
      recheck.push("date")
    end
    
    if time.nil?
      time = Time.now + (60*30)
      time = time.strftime("%l:%p")
      recheck.push("time")
    end
    
    if golfers.nil?
      golfers = 2
      recheck.push("golfers")
    end
    
    
    return {:golfers=>golfers,:date=>date,:time=>time,:recheck=>recheck}
  end
  
  
  
  def get_slots(course,date,time)

    dates = JSON.parse(course.available_times)
    @times = dates[date]["day"]
    ret = []
    closest = nil
    avail = []
    avail_full = []
    @times.each_with_index do |t, i|
      if t['t'] >= time
        closest = t['t']
        avail = []
        @times[i-2,5].each do |tt|
          avail.push(tt['t'])
          avail_full.push(tt)
        end
        break
      end
    end

    return closest,avail,avail_full
      
  end
  
end






















