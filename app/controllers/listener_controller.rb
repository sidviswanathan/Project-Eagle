require 'logger'
require 'chronic'
require 'date'

class ListenerController < ApplicationController
  
  skip_before_filter :verify_authenticity_token
  
  COURSE_MAP = {"Deep Cliff Golf Course" => "1"}
  COURSE_EMAILS = {"1" => "carlcwheatley@gmail.com"}
  
  def get_value(lab,text)
    return text.split(lab)[1].split("\n")[0].strip
  end
  
  def index
    
    #config = YAML::load(File.read(Rails.root.join('config/course.yml'))) 
    #logger.info config.keys
    
    if params["subject"] == 'Reservation Confirmation - Deep Cliff Golf Course'
      
      date        = Date.parse(Chronic.parse(params["text"].split("Tee Date:")[1].split("Tee Time:")[0].split(", ")[1]).strftime('%Y-%m-%d'))
      num_golfers = params["text"].split("Number of Players:")[1][1..1]
      time        = params["text"].split("Tee Time:")[1].split("Number of Players:")[0]
      tee_time    = Chronic.parse(time[1..time.length-2]).strftime('%H:%M')
      
      logger.info date.class
      logger.info 'THE TEE DATE IS: '+Chronic.parse(params["text"].split("Tee Date:")[1].split("Tee Time:")[0].split(", ")[1]).strftime('%Y-%m-%d')
      logger.info 'THE NUM GOLFERS IS IS: '+params["text"].split("Number of Players:")[1][1..1]
      logger.info 'THE TEE TIME IS: '+Chronic.parse(time[1..time.length-2]).strftime('%H:%M')
      
      r = Reservation.book_tee_time(COURSE_MAP["1"],"1",num_golfers,tee_time,date)

      
      
    
    elsif params["subject"] == 'Reservation Confirmation - GolfNow.com/San Francisco'
      text = params["text"]
      date = Date.strptime(get_value("Tee Date: ",text),"%A, %B %d, %Y").strftime('%Y-%m-%d')
      num_golfers = get_value("Number of Players: ",text)
      tee_time = Chronic.parse(get_value("Tee Time: ",text)).strftime('%H:%M')
      course_id = COURSE_MAP[get_value("Golf Course: ",text)]
      
      logger.info 'THE TEE DATE IS: '+date
      logger.info 'THE NUM GOLFERS IS: '+num_golfers
      logger.info 'THE TEE TIME IS: '+tee_time
      
      r = Reservation.book_tee_time(COURSE_MAP[course_id],course_id,num_golfers,tee_time,date)


      
    
    else
      #Send Admin Email if Subject not recognized  
    end  
    
    #IMPLEMENT
    #Move this into model code, should not be in application controller
    #create_reservation(config["deep_cliff"]["email"], config["deep_cliff"]["f_name"], date, tee_time, num_golfers, config["deep_cliff"]["course_id"])    
    
    render :nothing => true
    
  end  

end
