require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'lib/api/fore.rb'
require "net/http"
require "net/https"
require 'chronic'
require 'twiliolib'
require 'twilio-ruby'



class ServerCommunicationController < ApplicationController
  skip_before_filter :verify_authenticity_token 

  ADD_TASK_HOST                         = 'http://project-eagle.appspot.com'
  ADD_TASK_URI                          = '/schedule/'
  
  T_SID = 'ACc6377a248c5300434e40041d2bd1b9c3'
  T_TOKEN = '8fcabbf06e89b828c7d5b59fb583e38a'

  # set up a client to talk to the Twilio REST API
  
  
  def intitiate_response_object    
    response_object              = Hash.new
    response_object[:status]     = "failure"
    response_object[:statusCode] = 500
    response_object[:response]   = ""
    response_object[:message]    = "The server encountered an unexpected condition which prevented it from fulfilling the request"
    return response_object
  end
  
  def update_courses
    courses = Course.all
    courses.each do |course|
      DeviceCommunicationController::API_MODULE_MAP[course.api].update(course)
    end
    render :nothing => true
  end
  
  def add_course_media
    course = Course.find(params[:course_id])
    @info = JSON.parse(course.info)
    if params[:action] == 'logo'
      @info["logo"] = params[:url]
    else
      @info["gallery"].push(params[:url])
    end
    course.info = @info.to_json
    course.save
  end
  
  def perform_booking
    dump = Dump.find(params[:key].to_i)
    data = JSON.parse(dump.data)
    Reservation.book_tee_time(data["email"], data["course_id"], data["golfers"], data["time"], data["date"], data["total"])
    render :nothing => true
  end
  
  def self.schedule_booking(email, course_id, golfers, time, date, total)
    data = {"email"=>email,"course_id"=>course_id,"golfers"=>golfers,"time"=>time,"date"=>date,"total"=>total}
    course = Course.find(course_id.to_i)
    dates = JSON.parse(course.future_dates)
    if !dates["taken"].has_key?(date)
      dates["taken"][date] = 4
    end
    dates["taken"][date] -= golfers.to_i
    if dates["taken"][date] > -1
      course.future_dates = dates.to_json
      course.save
      dump = Dump.create({:data => data.to_json})
      eta_day = Date.parse(date) - 7
      eta_time = "06:00"
      query = "#{ADD_TASK_URI}perform_booking?key=#{dump.id.to_s}&d=#{eta_day}&t=#{eta_time}"
      url = URI.parse(ADD_TASK_HOST)
      http = Net::HTTP.new(url.host, url.port)
      http.use_ssl = false
      headers = {}

      response = http.get(query, headers)
      return {"confirmation_code"=>"none"}
    else
      return nil
    end
    
    
  end
  
  def self.schedule_cancel(confirmation_code,course_id,countdown)
    r = Reservation.find_by_confirmation_code(confirmation_code)
    data = {"confirmation_code"=>confirmation_code,"course_id"=>course_id}
    eta_day = Date.today.strftime("%Y-%m-%d")
    eta_time = (Time.now+countdown).strftime("%H:%M")
    dump = Dump.create({:data => data.to_json})

    query = "#{ADD_TASK_URI}perform_cancel?key=#{dump.id.to_s}&d=#{eta_day}&t=#{eta_time}"
    
    url = URI.parse(ADD_TASK_HOST)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = false
    headers = {}

    response = http.get(query, headers)
    
  end
  
  def self.perform_cancel
    dump = Dump.find(params[:key].to_i)
    data = JSON.parse(dump.data)
    Reservation.cancel(data["confirmation_code"],data["course_id"])
  end
  
  def self.schedule_contact(user,subject,body,date,time,sms,voice)
    data = {"f_name"=>user.f_name,"l_name"=>user.l_name,"email"=>user.email,"subject"=>subject,"body"=>body,"sms"=>sms,"voice"=>voice,"phone"=>user.phone}
    eta_day = date
    eta_time = time
    dump = Dump.create({:data => data.to_json})
    
    query = "#{ADD_TASK_URI}perform_#{user.contact_via}?key=#{dump.id.to_s}&d=#{eta_day}&t=#{eta_time}"
    
    url = URI.parse(ADD_TASK_HOST)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = false
    headers = {}

    response = http.get(query, headers)

  end
  

  
  def perform_phone
    dump = Dump.find(params[:key].to_i)
    @client = Twilio::REST::Client.new T_SID, T_TOKEN
    @call = @client.account.calls.create(
      :from => '+14087035664',
      :to => dump["phone"],
      :url => "http://www.presstee.com/voice/reminder?d=#{dump.id.to_s}"
    )
  end
  
  

  
  def perform_text
    dump = Dump.find(params[:key].to_i)
    @client = Twilio::REST::Client.new T_SID, T_TOKEN
    @client.account.sms.messages.create(
      :from => '+14087035664',
      :to => "#{dump['phone']}",
      :body => dump["sms"]
    )
  end
  

  
  def perform_email
    dump = Dump.find(params[:key].to_i)
    Mailer.deliver_reminder(JSON.parse(dump.data))
    render :nothing => true
  end
  

  
  
end