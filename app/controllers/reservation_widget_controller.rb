class ReservationWidgetController < ApplicationController

  $course = 1
  $book_period = 7
  $max_golfers = 4

  def index
    @golfers = $max_golfers
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
    form_datePicker = params[:pick_date]
    @date = Date.today
    @date = form_datePicker[:pick_date] unless params[:pick_date].nil?
    @tee_slots_for_date = show_available_tee_slots_for_date(@date, $course)
    puts @tee_slots_for_date 
    @tee_slots_for_date = @tee_slots_for_date.sort
  end
end
