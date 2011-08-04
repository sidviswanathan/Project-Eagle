require 'logger'

class ListenerController < ApplicationController
  skip_before_filter :verify_authenticity_token
  
  def index
    logger.info params.keys
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
