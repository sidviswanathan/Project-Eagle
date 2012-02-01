require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'lib/api/fore.rb'



class ServerCommunicationController < ApplicationController 

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
  
  def schedule_mailing(data,eta)
    dump = Dump.create({:data => data.to_json})
    
    query = "#{ADD_TASK_URI}perform_reminder?key=#{dump.id}&dt=#{eta}"
    
    url = URI.parse(ADD_TASK_HOST)
    http = Net::HTTP.new(url.host, url.port)
    headers = {}
    
    response = http.get(query, headers)
    render :nothing => true
    
  end
  
  def perform_reminder
    dump = Dump.find(params[:key].to_i)
    ConfirmMailer.deliver_reminder(dump)
  end
  
  def test_schedule
    data = {"f_name"=>"Arjun","l_name"=>"Vasan","email"=>"arjun.vasan@gmail.com"}
    eta = "2012-02-01 08:00"
    schedule_mailing(data,eta)
    render :nothing => true
  end
  
  
end