class ConfirmMailer < ActionMailer::Base
  def reminder(data)
    recipients "#{data['f_name']} #{data['l_name']} <#{data['email']}>"
    from       "Deep Cliff Golf Course"
    subject    "Tee Time Reservation Reminder"
    sent_on    Time.now
    body       "Dear #{data['f_name']} #{data['l_name']}\n\nPlease remember to cancel your reservation if you are not planning on showing up.\n\nThank you, come again, Deep Cliff"
  end
end
