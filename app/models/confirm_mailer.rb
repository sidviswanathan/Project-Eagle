class ConfirmMailer < ActionMailer::Base
  def signup_notification(email)
    recipients "Arjun Vasan <#{email}>"
    from       "My Forum "
    subject    "Please activate your new account"
    sent_on    Time.now
    body       "Hellow"
  end
end
