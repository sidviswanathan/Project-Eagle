class ConfirmMailer < ActionMailer::Base
  def signup_notification(email)
    recipients "Arjun Vasan <#{email}>"
    from       "PressTee booking"
    subject    "Please activate your new account"
    sent_on    Time.now
    body       "Hellow"
  end
end
