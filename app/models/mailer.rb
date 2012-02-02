class Mailer < ActionMailer::Base
  SIGNATURE = <<-eos
      Deep Cliff Golf Course <deepcliff@presstee.com>
      10700 Clubhouse Lane 
      Cupertino, California 95014
      Phone # 408.253.5357 / FAX # 408.253.4521
    eos
  def reminder(data)
    recipients "#{data['f_name']} #{data['l_name']} <#{data['email']}>"
    from       "Deep Cliff Golf Course <deepcliff@presstee.com>"
    subject    data['subject']
    sent_on    Time.now
    body       "Dear #{data['f_name'].capitalize} #{data['l_name'].capitalize}\n\n#{data['body']}\n\n#{SIGNATURE}"
  end

end
