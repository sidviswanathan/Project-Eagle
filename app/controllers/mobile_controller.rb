class MobileController < ApplicationController
  skip_before_filter :verify_authenticity_token 

  ADD_TASK_HOST                         = 'http://project-eagle.appspot.com'
  ADD_TASK_URI                          = '/schedule/'
  
  def intitiate_response_object    
    response_object              = Hash.new
    response_object[:status]     = "failure"
    response_object[:statusCode] = 500
    response_object[:response]   = ""
    response_object[:message]    = "The server encountered an unexpected condition which prevented it from fulfilling the request"
    return response_object
  end
  
  def index
    @course = Course.find(1)
    @params = params
    @date = "2012-"
  end

end
