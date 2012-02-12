require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'lib/api/fore.rb'
require "net/http"
require "net/https"



class ServerCommunicationController < ApplicationController
  skip_before_filter :verify_authenticity_token 

  ADD_TASK_HOST                         = 'http://project-eagle.appspot.com'
  ADD_TASK_URI                          = '/schedule/'
  
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
      eta_time = "07:00"
      query = "#{ADD_TASK_URI}perform_reminder?key=#{dump.id.to_s}&d=#{eta_day}&t=#{eta_time}"
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
  
  
  def self.schedule_mailing(user,subject,body,date,time)
    data = {"f_name"=>user.f_name,"l_name"=>user.l_name,"email"=>user.email,"subject"=>subject,"body"=>body}
    eta_day = date
    eta_time = time
    dump = Dump.create({:data => data.to_json})

    query = "#{ADD_TASK_URI}perform_reminder?key=#{dump.id.to_s}&d=#{eta_day}&t=#{eta_time}"
    
    url = URI.parse(ADD_TASK_HOST)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = false
    headers = {}

    response = http.get(query, headers)
  end
  
  def perform_reminder
    dump = Dump.find(params[:key].to_i)
    Mailer.deliver_reminder(JSON.parse(dump.data))
    render :nothing => true
  end
  

  
  
end