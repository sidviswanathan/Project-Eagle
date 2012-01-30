class Notifier < ActionMailer::Base

  # send a signup email to the user, pass in the user object that contains the user's email address
  def signup_email(email)
    mail( :to => email, 
          :from => "test@presstee.com"
          :subject => "Thanks for signing up" )
  end
end