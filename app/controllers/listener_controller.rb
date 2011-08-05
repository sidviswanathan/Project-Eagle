require 'logger'
require 'chronic'

class ListenerController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  
  def index
    
    config = YAML::load(File.read(Rails.root.join('config/course.yml'))) 
    logger.info config.keys
    
    if params["subject"] == 'Reservation Confirmation - Deep Cliff Golf Course'
      
      date        = Date.parse(Chronic.parse(params["text"].split("Tee Date:")[1].split("Tee Time:")[0].split(", ")[1]).strftime('%Y-%m-%d'))
      num_golfers = params["text"].split("Number of Players:")[1][1..1]
      time        = params["text"].split("Tee Time:")[1].split("Number of Players:")[0]
      tee_time    = Chronic.parse(time[1..time.length-2]).strftime('%H:%M')
      
      logger.info date.class
      logger.info 'THE TEE DATE IS: '+Chronic.parse(params["text"].split("Tee Date:")[1].split("Tee Time:")[0].split(", ")[1]).strftime('%Y-%m-%d')
      logger.info 'THE NUM GOLFERS IS IS: '+params["text"].split("Number of Players:")[1][1..1]
      logger.info 'THE TEE TIME IS: '+Chronic.parse(time[1..time.length-2]).strftime('%H:%M')
    else
      #Send Admin Email if Subject not recognized  
    end  
    
    #IMPLEMENT
    #Move this into model code, should not be in application controller
    create_reservation(config["deep_cliff"]["email"], config["deep_cliff"]["f_name"], date, tee_time, num_golfers, config["deep_cliff"]["course_id"])    
    
    render :nothing => true
    
  end  

end
