class ReservationWidgetController < ApplicationController

  $course = 1
  $book_period = 7
  $user_email = "reservation@DeepCliff.com"
  $name = "DeepCliff"

  def index
    datePicker
    teeSlotPicker
  end

  def cancelIndex
    cancelDatePicker
    showReservations
  end

  def showReservations
    @date = Date.today
    @date = params[:pickDate][:pick_date] unless params[:pickDate].nil?
    @tee_slots_booked_for_date = show_booked_tee_slots_for_date(@date, $course)
    @tee_slots_booked_for_date = @tee_slots_booked_for_date.sort
  end

  def datePicker
    if @book_dates.nil?
      @book_dates = Array.new
    end
    if @book_dates[0] != Date.today
      for i in 0..$book_period
        @book_dates << Date.today + i
      end
    end
  end

  def cancelDatePicker
    if @book_dates.nil?
      @book_dates = Array.new
    end
    if @book_dates[0] != Date.today
      for i in 0..$book_period
        @book_dates << Date.today + i
      end
    end
  end

  def teeSlotPicker
    @date = Date.today
    @date = params[:pickDate][:pick_date] unless params[:pickDate].nil?
    @tee_slots_for_date = show_available_tee_slots_for_date(@date, $course)
    @tee_slots_for_date = @tee_slots_for_date.sort
  end

  def reserveTime
    if !params[:reservation].nil?
      teeTime = params[:reservation][:teeTime]
      teeSlots = params[:reservation][:golfers]
      teeDate = params[:reservation][:date]
      create_reservation($user_email, $name, teeDate, teeTime, teeSlots, $course) 
    end
    flash[:notice] = "Last reservation on #{teeDate} at #{teeTime} for #{teeSlots}"
    redirect_to :action => :index
  end

  def cancelReservation
    if !params[:cancellation].nil?
      teeTime = params[:cancellation][:teeTime]
      teeDate = params[:cancellation][:date]
      cancel_reservation($user_email, teeDate, teeTime)
    end
    flash[:notice] = "Last cancellation on #{teeDate} at #{teeTime}"
    redirect_to :action => :cancelIndex
  end

end
