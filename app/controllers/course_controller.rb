require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'lib/api/fore.rb'




class CourseController < ApplicationController
  skip_before_filter :verify_authenticity_token 
  
  def add
  end
  
  def edit
    @course = Course.find(params[:id].to_s)
    @course_info = JSON.parse(@course.info)
    @course_matrix = JSON.parse(@course.fee_matrix)
    
  end
  
  def index
    @courses = Course.all
  end
  
end