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
    @uName = params[:email]
    @fName = params[:fName]
    @lName = params[:lName]
    @dateRequest = params[:date]
    @teeTimeSlotRequest = params[:teeTimeSlot]
    @numGolfers = params[:golfers]
    puts @uName
    puts @fName
    if @uName != nil
      respond_to do |format|
        format.json { render :json => TEE_TIME_SLOTS }
      end
    else
      render :text => "Enter valid email id"
    end
  end

end
