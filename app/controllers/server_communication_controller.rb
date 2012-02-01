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

  ADD_TASK_HOST                         = 'http://dump-them.appspot.com'
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
  
  def schedule_mailing(user,subject,body,date,time)
    data = {"f_name"=>user.f_name,"l_name"=>user.l_name,"email"=>user.email,"subject"=>subject,"body"=>body}
    eta_day = date
    eta_time = time
    dump = Dump.create({:data => data.to_json})

    query = "/schedule/perform_reminder?key=#{dump.id.to_s}&d=#{eta_day}&t=#{eta_time}"
    
    url = URI.parse("http://dump-them.appspot.com")
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = false
    headers = {}

    response = http.get(query, headers)
    
    render :nothing => true

    
  end
  
  def perform_reminder
    dump = Dump.find(params[:key].to_i)
    ConfirmMailer.deliver_reminder(JSON.parse(dump.data))
    render :nothing => true
  end
  
  def test_schedule
    confirmation = <<-eos
        Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor 
        incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud 
        exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute 
        irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla 
        pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia
        deserunt mollit anim id est laborum.
      eos
    puts confirmation
    
    render :nothing => true
    #schedule_mailing(data,eta)

  end
  
  
end