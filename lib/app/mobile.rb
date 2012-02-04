require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'lib/api/fore.rb'

class MobileApp
  attr_accessor :course, :time, :golfers, :date, :params, :d2, :d, :times, :ampm, :request
  def initialize(params,request)
    @course = Course.find(params[:course_id].to_i)
    if params[:time].nil?
      params[:time] = ""
    end
    if params[:date].nil?
      params[:date] = Date.today.strftime("%Y-%m-%d")
    end
    
    @time = params[:time]
    @ampm = Time.parse(@time).strftime("%p")
    @golfers = params[:golfers]
    @date = params[:date]
    @params = params
    @request = request
    today = Date.today
    
    @d2 = (0..6).map {|x| (today+x).strftime("%A, %B %e")}
    @d = (0..6).map {|x| (today+x).strftime("%Y-%m-%d")}
    
    begin
      dates = JSON.parse(@course.available_times)
      @times = dates[params[:date]]["day"]
    rescue
    end
    
  end
  
  def get_query
    kvs = []
    @params.each_pair do |k,v|
      kvs.push(k+"="+v)
    end
    return "?#{kvs.join('&')}"
  end
  
  def course_info
    return JSON.parse(@course.info)
  end
  
  def get_url(action,new_params)
    @params = @params.merge(new_params)
    uri = "/mobile/#{action}#{get_query}"
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