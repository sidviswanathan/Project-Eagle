require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'lib/api/fore.rb'
require 'lib/app/mobile.rb'

# This is the controller for the mobile web app version
# Below is the expected format for paramters received from all client devices

# ==========================================
# = DEFINE STANDARD PARAMETER FORMATS ======
# ==========================================

# course_id           => '1'                (String, Required)   
# golfers             => '2'                (String)   
# time                => '07:14'            (String)   
# date                => '2011-05-11'       (String)
# f_name              => 'first_name'       (String)
# l_name              => 'last_name'        (String)
# email               => 'name@domain.com'  (String)

# ==========================================
# =========== Controller Actions ===========
# ==========================================

# booking             => '/mobile/'         
# golfer select       => '/mobile/num'   
# date_select         => '/mobile/date'   
# time_select         => '/mobile/time'   
# reservations        => '/mobile/reservations'   
# view reservation    => '/mobile/view'   
# about us            => '/mobile/about'   


class MobileController < ApplicationController
  
  before_filter :get_mobile_app
  skip_before_filter :verify_authenticity_token 

  # http://m.playdeepcliff.com/ is the same as http://www.presstee.com/mobile/?course_id=1
  # http://localhost:3000/mobile?course_id=1 (To access via localhost) 
  
  def get_mobile_app
    mdomain = request.url.sub("http://","").split("/")[0]
    if mdomain == 'pric.io' or params[:pricio] == "true" 
      render :template => "web/pricio"                                      # Render the company landing page
    else                                                                    # Otherwise, render the appropriate mobile booking experience depending on course
      course = Course.find_by_mobile_domain(mdomain)
      params[:course_id] = course.id.to_s if !course.nil?  
      params[:course_id] = 1 if Rails.env.to_s =="development"
      
      puts "##################################################"
      puts mdomain
      puts course
      pp params
      puts "##################################################"
  
      @app = MobileApp.new(params,request,session)
    end
  end
  
  def confirm
    dog = "nothing"
  end
  
  def booking
    if params[:exp] == "true"
      redirect_to @app.get_url("index_exp",{:xui=>"true",:exp=>"true"})
    elsif params[:xui] == "true"
      redirect_to @app.get_url("index_xui",{:xui=>"true"})
    elsif params[:ajax] == "true"
      render :template => "mobile/booking_ajax"
    end
  end
  
  def index
    if params[:exp] == "true"
      redirect_to @app.get_url("index_exp",{:xui=>"true",:exp=>"true"})
    elsif params[:xui] == "true"
      redirect_to @app.get_url("index_xui",{:xui=>"true"})
    end
  end
  
  def book
    if params[:exp] == "true"
      redirect_to @app.get_url("index_exp",{:xui=>"true",:exp=>"true"})
    elsif params[:xui] == "true"
      redirect_to @app.get_url("index_xui",{:xui=>"true"})
    end
  end
  
  def more_days
    @app.more_days(params[:last])
  end
  
  def index_exp    
  end
  def index_xui
    @render_head = true
    @app.params[:xui] = "true"
    if params[:xhr] == 'true'
      @render_head = false
    end
  end
  def mobile_agent?
    request.user_agent =~ /Mobile|webOS/
  end
  def android?
    request.user_agent =~ /Android/
  end
  def blackberry?
    request.user_agent =~ /BlackBerry/
  end
  def windows?
    request.user_agent =~ /Windows/
  end
  def symbian?
    request.user_agent =~ /Symbian/
  end
  def iframe
    @is_mobile = mobile_agent?
    @request = request
    #puts request.user_agent
  end
  def iframe_test
    
  end
  
  
end
