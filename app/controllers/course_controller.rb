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
  
  
  def save
    if !session[:manager].nil?
      @manager = session[:manager]
      @new_course = false
      if params[:id] == 'new'
        @course = Course.default
        @new_course = true
      else
        @course = Course.find(params[:id].to_s)
      end
      if params[:save] == '#info'
        @course_info = JSON.parse(@course.info)
        @course_info["title"] = params[:title]
        @course_info["title_short"] = params[:title_short]
        @course_info["address"] = {
          "city" => params[:city],
          "state" => params[:state],
          "zip" => params[:zip],
          "street" => params[:street]
        }
        @course_info["url"] = params[:url]
        
        @course.info = @course_info.to_json
        @course.api = params[:api]
        @course.api_course_id = params[:api_course_id]
        @course.mobile_domain = params[:mobile_domain]
        @course.web_domain = params[:web_domain]
        @course.name = params[:title_short]
        @course.save
        
        
        @mcourses = JSON.parse(session[:manager].courses)
        if !@mcourses['list'].include? @course.id
          @mcourses["list"].push(@course.id)
          session[:manager].courses = @mcourses.to_json
          session[:manager].save
        end
        render :text => @course.id.to_s
        #redirect_to "/course/edit/"+params[:id].to_s
      elsif params[:save] == '#settings'
        
      elsif params[:save] == "#manager"
        #m = Manager.create({email})
        
      end
    end
  end
  
  def get_times
    
  end
  
  def messenger
    
  end
  
  def photos
    client = GData::Client::Photos.new
    client.clientlogin('pressteex@gmail.com', 'presstee1')
  end
  
  def add_slots(v)
    s = 0
    v.each do |t|
      s += t['q'].to_i
    end
    return s
  end
  
  def get_slots_left(hours)
    sum = {}
    hours.each_pair do |time,v|
      sum[time.split(":")[0].to_i] = add_slots(v)
    end
    return sum
    
  end
  
  def get_slots_left_day(day)
    total = 0
    day.each do |t|
      total += t["q"].to_i
    end
    return total.to_s
  end
  
  def advanced_sale
    
  end
  
  def analytics
    c = Course.find(params[:id])
    dates = JSON.parse(c.available_times)
    @inventory = {}
    dates.each_pair do |k,v|
      @inventory[k] = get_slots_left_day(v["day"])
    end

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
      if @courses_acl['list'] == [] 
        @courses = Course.all
      else
        @courses = Course.find(@courses_acl['list'])
      end
    else
      @courses = nil
    end
    
  end
  
end