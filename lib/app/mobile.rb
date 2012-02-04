require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'lib/api/fore.rb'

class MobileApp
  attr_accessor :course, :time, :golfers, :date, :params, :d2, :d, :times, :ampm
  def initialize(params)
    @course = Course.find(params[:course_id].to_i)
    if params[:time].nil?
      params[:time] = ""
    end
    if params[:date].nil?
      params[:date] = Date.today.strftime("%Y-%m-%d")
    end
    
    df = "%A, %B %e"
    dff = "%Y-%m-%d"
    @time = params[:time]
    @ampm = Time.parse(@time).strftime("%p")
    @golfers = params[:golfers]
    @date = params[:date]
    @date_ob = Date.parse(params[:date])
    @params = params
    d = Date.today
    
    @d2 = (0..6).map {|x| (d+x).strftime(df)}
    @d = (0..6).map {|x| (d+x).strftime(dff)}
    
    #@d2 = [d.strftime(df),(d+1).strftime(df),(d+2).strftime(df),(d+3).strftime(df),(d+4).strftime(df),(d+5).strftime(df),(d+6).strftime(df)]
    
    #@d = [d.strftime("%Y-%m-%d"),(d+1).strftime("%Y-%m-%d"),(d+2).strftime("%Y-%m-%d"),(d+3).strftime("%Y-%m-%d"),(d+4).strftime("%Y-%m-%d"),(d+5).strftime("%Y-%m-%d"),(d+6).strftime("%Y-%m-%d")]
    
  end
  def get_query
    kvs = []
    @params.each_pair do |k,v|
      kvs.push(k+"="+v)
    end
    return "?#{kvs.join('&')}"
  end
  def get_url(action,new_params)
    @params = @params.merge(new_params)
    uri = "/mobile/#{action}#{get_query}"
  end
end