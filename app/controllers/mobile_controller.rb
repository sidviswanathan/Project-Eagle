require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'lib/api/fore.rb'
require 'lib/app/mobile.rb'

class MobileController < ApplicationController
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
  
  def get_mobile_app(params)
    return MobileApp.new(params)
  end
  
  
  def index
    @app = get_mobile_app(params)
    response_object = intitiate_response_object
    render 'mobile/index'
    
  end
  
  def app_num
    @app = get_mobile_app(params)
    response_object = intitiate_response_object
    render 'mobile/num'
    
  end
  
  def app_date
    @app = get_mobile_app(params)
    response_object = intitiate_response_object
    render 'mobile/date'
    
  end
  
  def app_test
    render 'mobile/test'
  end
  
  def app_times
    @app = get_mobile_app(params)
    @times = Course.get_available_times(@app.course,params[:date])
    response_object = intitiate_response_object
    render 'mobile/time'
    
  end

end
