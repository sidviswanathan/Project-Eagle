class ConfirmMailer < ActionMailer::Base
  def signup_notification(email)
    recipients "<#{email}>"
    from       "PressTee booking <confirm@mail.presstee.com>"
    subject    "Please confirm or cancel your booking"
    sent_on    Time.now
    body       "Hellow"
  end
end
