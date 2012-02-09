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
      @course = Course.find(params[:id].to_s)
      @course_info = JSON.parse(@course.info)
      @course_matrix = JSON.parse(@course.fee_matrix)
    else
      redirect_to "/course/"
    end
    
    
    
  end
  
  def logout
    session[:manager] = nil
    redirect_to "/course/"
  end
  
  def login
    if request.post?
      m = Manager.find_by_email(params[:email])
      if !m.nil?
        if m.password == params[:password]
          session[:manager] = m
          redirect_to "/course/"
        end
      end
    end
    
  end
  
  def index
    if !session[:manager].nil?
      @manager = session[:manager]
      @courses = Course.find(JSON.parse(session[:manager].courses))
    else
      @courses = nil
    end
    
  end
  
end