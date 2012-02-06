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
  
  # booking             => '/mobile/'         
  # golfer select       => '/mobile/num'   
  # date_select         => '/mobile/date'   
  # time_select         => '/mobile/time'   
  # reservations        => '/mobile/reservations'   
  # view reservation    => '/mobile/view'   
  # about us            => '/mobile/about'   
  
=end

class MobileController < ApplicationController
  before_filter :get_mobile_app
  skip_before_filter :verify_authenticity_token 

  def get_mobile_app
    @app = MobileApp.new(params,request,session)
  end
  
  def index_xui
    @render_head = true
    if params[:xhr] == 'true'
      @render_head = false
    end
  end
  
end
