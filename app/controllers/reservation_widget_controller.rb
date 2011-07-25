class ReservationWidgetController < ApplicationController

  $book_period = 7
  $max_golfers = 4
  $course = 1

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
    @date = form_datePicker[:pick_date]
    puts "#### Inside def teeSlotPicker ########"
    puts @date
    @tee_slots_for_date = show_available_tee_slots_for_date(@date, $course)
    @tee_slots_for_date = @tee_slots_for_date.sort
  end
end
