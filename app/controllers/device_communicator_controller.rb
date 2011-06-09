class DeviceCommunicatorController < ApplicationController

  def index
  end
  
  def fetch_string
    render :text => "Hello"
  end  
  
  def fetch_object
    @object = "return"
    respond_to do |format|
      format.json { render :json => @object }
    end
  end

  # Post send_object
  def send_object
    @object = params[:username]
    puts @object
    if @object == "Amar"
      respond_to do |format|
        format.json { render :json => TEE_TIME_SLOTS }
      end
    else
      render :text => "Access denied"
    end
  end

end
