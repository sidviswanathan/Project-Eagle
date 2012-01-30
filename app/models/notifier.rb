class Notifier < ActionMailer::Base
  default :from => "test@presstee.com"

  # send a signup email to the user, pass in the user object that contains the user's email address
  def signup_email(email)
    mail( :to => email, 
          :subject => "Thanks for signing up" )
  end
end