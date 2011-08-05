require 'logger'
require 'chronic'

class ListenerController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def index
    logger.info params.keys
    logger.info '################################'
    logger.info params["subject"]
    logger.info params["from"]
    logger.info params["to"]
    logger.info '###############################'
    
    logger.info '!!!!!!!!!!!!!!!!!!!!!!!!!!!!' if params["subject"] == 'Reservation Confirmation - Deep Cliff Golf Course'
    logger.info '00000000000000000000000000000000000000'
    logger.info '00000000000000000000000000000000000000'
    logger.info params["text"].split("Tee Date:").split(", ")[1]
    logger.info '00000000000000000000000000000000000000'
    logger.info '00000000000000000000000000000000000000'
    logger.info params["text"].split("Number of Players:")[1][1..1]
    logger.info params["text"].split("Tee Time:").split("Number of Players:")[0]
    logger.info Chronic.parse("August 30").strftime('%Y-%m-%d')
    
    #[1..time.length-2]
    
    #Reservation.create(:)
    #Reservation(id: integer, date: date, tee_slot: string, availability: boolean, golfers: integer, user_id: integer, course_id: integer, created_at: datetime, updated_at: datetime)
    
    
    # @params = params
    #Make sure request is a post
    # @inbound_email = InboundEmail.new(:text => params["text"],
    #                                       :html => params["html"],
    #                                       :to => clean_field(params["to"]),
    #                                       :from => clean_field(params["from"]),
    #                                       :subject => clean_field(params["subject"])
    #                                       )           
    #     respond_to do |format|                               
    #       if @inbound_email && request.post?
    #         @inbound_email.process_incoming_email
    #         flash[:notice] = 'Item was successfully created'
    #         format.xml { render :xml => @inbound_email, :status => :created}
    #       else
    #         flash[:notice] = 'Error saving the item'
    #         format.xml { render :xml => @inbound_email.errors, :status => :unprocessable_entity}
    #       end  
    #     end 
    render :nothing => true
  end  
  
  private
  
  def clean_field(input_string)
    input_string.gsub(/\n/,'') if input_string
  end  


end
