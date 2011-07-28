class ReservationWidgetController < ApplicationController

  $course = 1
  $book_period = 7
  $max_golfers = 4

  def index
    if @book_dates.nil?
      @book_dates = Array.new
    end
    if @book_dates[0] != Date.today
      for i in 0..$book_period
        @book_dates << Date.today + i
      end
    end
    teeSlotPicker
  end

  def teeSlotPicker
    @date = Date.today
    @date = params[:pickDate][:pick_date] unless params[:pickDate].nil?
    @tee_slots_for_date = show_available_tee_slots_for_date(@date, $course)
    @tee_slots_for_date = @tee_slots_for_date.sort
  end

  def reserveTime
    @golfers = $max_golfers
    puts params[:reservation]
    if !params[:reservation].nil?
      teeTime = params[:reservation][:teeTime]
      teeSlots = params[:reservation][:teeSlots]
      teeDate = params[:reservation][:date]
      user_email = "reservation@DeepCliff.com"
      name = "DeepCliff"
      create_reservation(user_email, name, teeDate, teeTime, teeSlots, $course) 
    end
    redirect_to :action => :index
  end
end
