class ConfirmMailer < ActionMailer::Base
  SIGNATURE = <<-eos
      Thank you,
      Deep Cliff Golf Course (via PressTee)
      http://www.playdeepcliff.com/
    eos
  def reminder(data)
    recipients "#{data['f_name']} #{data['l_name']} <#{data['email']}>"
    from       "Deep Cliff Golf Course <reminder@presstee.com>"
    subject    data['subject']
    sent_on    Time.now
    body       "Dear #{data['f_name']} #{data['l_name']}\n\n#{data['body']}\n\n#{SIGNATURE}"
  end

end
