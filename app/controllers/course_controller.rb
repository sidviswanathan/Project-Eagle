require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'lib/api/fore.rb'

class CourseController < ApplicationController
  skip_before_filter :verify_authenticity_token 
  
  def add
  end
  
  def edit
    if !session[:manager].nil?
      @manager = session[:manager]
      @new_course = false
      if params[:id] == 'new'
        @course = Course.default
        @new_course = true
      else
        @course = Course.find(params[:id].to_s)
      end  
      @course_info = JSON.parse(@course.info)
      @course_matrix = JSON.parse(@course.fee_matrix)
      if !@course.available_times.nil?
        @course_times = JSON.parse(@course.available_times)
      end
    else
      redirect_to "/course/"
    end
    
  
  end
  
  def get_times
    
  end
  
  def logout
    session[:manager] = nil
    redirect_to "/course/"
  end
  
  def login
    if request.post?
      if session[:manager] = Manager.authenticate(params[:email], params[:password])
        flash[:message]  = "Login successful"
        redirect_to "/course/"
      else
        flash[:warning] = "Login unsuccessful"
      end
    end
    
  end
  
  def index
    if !session[:manager].nil?
      @manager = session[:manager]
      @courses_acl = JSON.parse(session[:manager].courses)
      @courses = Course.find(@courses_acl['list'])
    else
      @courses = nil
    end
    
  end
  
end