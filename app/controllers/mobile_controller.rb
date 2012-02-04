require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'lib/api/fore.rb'
require 'lib/app/mobile.rb'

class MobileController < ApplicationController
  before_filter :get_mobile_app
  skip_before_filter :verify_authenticity_token 
  

  ADD_TASK_HOST                         = 'http://project-eagle.appspot.com'
  ADD_TASK_URI                          = '/schedule/'
  
  @app = nil
  

  
  def get_mobile_app
    @app = MobileApp.new(params)
  end
  
  


end
