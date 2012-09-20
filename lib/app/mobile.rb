require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'lib/api/fore.rb'

class MobileApp
  
  attr_accessor :course, :time, :golfers, :date, :params, :d2, :d, :times, :ampm, :request, :user, :total, :reservations, :reservation, :time12, :timenow, :date_tomorrow
  
  def initialize(params,request,session)
    @course = Course.find(params[:course_id].to_i)
    
    if params[:time].nil?
      params[:time] = ""
    end
    if params[:date].nil?
      params[:date] = Date.today.strftime("%Y-%m-%d")
    end
    
    @timenow        = Time.now 
    @time           = params[:time]
    @time12         = Time.parse(@time).strftime("%I:%M")
    @ampm           = Time.parse(@time).strftime("%p")
    @golfers        = params[:golfers]
    @date           = params[:date]
    @date_tomorrow  = (Date.today + 1.day).strftime("%Y-%m-%d")
    @params         = params
    @request        = request
    @reservations   = []
      
    begin
      @total = (params[:golfers].to_i * params[:price].to_i).to_s
    rescue
      @total = ""
    end
    
    #View is which reservation to look at by reservation id
    @reservation = nil
    if !params[:view].nil?
      @reservation = Reservation.find(params[:view].to_i)
    end
    
    @user ||= session[:current_user_id] && Customer.find_by_id(session[:current_user_id]) && Customer.find_by_id(cookies[:current_user_id].to_i)
    
    if !@user.nil?
      @reservations = Reservation.find_all_by_customer_id_and_course_id_and_status_code(
        @user.id,
        @course.id,
        Reservation::BOOKING_SUCCESS_STATUS_CODE,
        :order=>"date DESC,time DESC"
        )
    end
        
    today = Date.today
    @d2 = (0..6).map {|x| (today+x).strftime("%A, %B %e")}
    @d = (0..6).map {|x| (today+x).strftime("%Y-%m-%d")}
    
    # Get list of available tee times from the DB
    dates = JSON.parse(@course.available_times)
    if !dates.has_key?(date)
      dates = JSON.parse(@course.future_dates)
      
      if !dates.has_key?(date)
        dates[date] = dates["template"]
        @course.future_dates = dates.to_json
        @course.save
      end
      @times = dates[date]
    else
      @times = dates[params[:date]]["day"]
    end
    
  end
  
  def more_days(last)
    last = Date.parse(last) + 1
    @d2 = (0..6).map {|x| (last+x).strftime("%A, %B %e")}
    @d = (0..6).map {|x| (last+x).strftime("%Y-%m-%d")}
  end
  
  def prev_date
    return (Date.parse(@date)-1).strftime("%Y-%m-%d")
  end
  
  def next_date
    return (Date.parse(@date)+1).strftime("%Y-%m-%d")
  end
  
  def get_user_email
    if !@user.nil? 
      return @user.email
    else
      return ""
    end
  end
  
  def get_user_contact
    if !@user.nil?
      if @user.contact_via == 'email'
        return @user.email
      else
        return @user.phone
      end
    else
      return ""
    end
  end
  
  def get_user_contact_via
    if !@user.nil?
      return @user.contact_via
    else
      return ""
    end
  end
  
  def get_user_fname
    if !@user.nil? 
      return @user.f_name
    else
      return ""
    end
  end
  
  def get_user_lname
    if !@user.nil? 
      return @user.l_name
    else
      return ""
    end
  end
  
  # When you click on the golfers link for example, the params that are past in are done 
  def get_query
    kvs = []
    @params.each do |k,v|
      #kvs.push(k+"="+v)
      kvs.push(k.to_s+"="+v.to_s)
    end
    return "?#{kvs.join('&')}"
  end
  
  def course_info
    return JSON.parse(@course.info)
  end
  
  # get_query is another method that can be run by calling it like this
  def get_url(action,new_params)
    @params = @params.merge(new_params)
    uri = "/#{action}#{get_query}"
  end
  
  def is_active(act)
    uri = @request.url.split("/")[-1].split("?")[0]
    if uri == act
      return true
    else
      return false
    end
  end
end