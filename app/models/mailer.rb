class Mailer < ActionMailer::Base
  
  include SendGrid
  sendgrid_enable :ganalytics, :opentrack, :clicktrack
  helper :application
  
  SIGNATURE = <<-eos
      Deep Cliff Golf Course <deepcliff@presstee.com>
      10700 Clubhouse Lane 
      Cupertino, California 95014
      Phone # 408.253.5357 / FAX # 408.253.4521
    eos
    
  def confirmation_email(reservation_info)
    pp reservation_info
    
    recipients        "sid.viswanathan@gmail.com"
    from              "Deep Cliff Golf Course<info@prestee.com>"
    subject           "Tee Time Confirmation: #{reservation_info["teetime"]}"
    body              :reservation => reservation_info
    content_type      "text/html"
    sendgrid_category "Tee Time Confrimation"
  end  
  
  def cancelation_email(c)
    recipients        c.email
    from              "Deep Cliff Golf Course<donotreply@prestee.com>"
    subject           "Tee Time Cancelation"
    body              :customer => c
    content_type      "text/html"
    sendgrid_category "Tee Time Cancelation"    
  end
  
  def reminder(data)
    recipients "#{data['f_name']} #{data['l_name']} <#{data['email']}>"
    from       "Deep Cliff Golf Course <deepcliff@presstee.com>"
    subject    data['subject']
    sent_on    Time.now
    body       "Dear #{data['f_name'].capitalize} #{data['l_name'].capitalize}\n\n#{data['body']}\n\n#{SIGNATURE}"
  end
  
  def api_booking_error(response)
    recipients        "carlcwheatley@gmail.com,sid.viswanathan@gmail.com"
    from              "Prestee<info@prestee.com>"
    subject           "Error from Fore API"
    body              :response => response
    content_type      "text/html"
  end
  
  def test_email(c)
    recipients        "carlcwheatley@gmail.com,sid.viswanathan@gmail.com"
    from              "Prestee<info@prestee.com>"
    subject           "Test Email"
    body              :customer => c
    content_type      "text/html"
  end
    
end
