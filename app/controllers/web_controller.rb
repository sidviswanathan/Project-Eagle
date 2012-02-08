require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'lib/api/fore.rb'
require 'lib/app/mobile.rb'

=begin

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
  
  # booking             => '/web/'         
  # golfer select       => '/web/num'   
  # date_select         => '/web/date'   
  # time_select         => '/web/time'   
  # reservations        => '/web/reservations'   
  # view reservation    => '/web/view'   
  # about us            => '/web/about'   
  
=end

class WebController < ApplicationController
  before_filter :get_mobile_app
  skip_before_filter :verify_authenticity_token 

  def get_web_app
    @app = MobileApp.new(params,request,session)
  end
  def index
    if params[:xui] == "true"
      redirect_to @app.get_url("index_xui",{})
    end
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
  def iframe
    @is_mobile = mobile_agent?
    @request = request
    #puts request.user_agent
  end
  def iframe_test
    
  end
  
  
end