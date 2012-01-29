desc "Fetch all Email Reservation records rom db, update them in the Reservation table, then delete each record"
task :update_email_reservations => :environment do
  emails = EmailReservation.all
  
  emails = User.find_each(:select => "date, time, golfers, course_id") do |email|
    r = Reservation.find_by_date_and_time_and_golfers(email.date,email.time,email.golfers)
    if r
      r.update_attributes :booking_type => 'email' 
      ucr
      
    end
    email.destroy
  end
  
  

  
  
  ctr = 0
  users = User.all
  users.each do |user|
    user.update_attribute(:user_identifier, Digest::MD5.hexdigest((Time.now.to_s) + rand(1542395823049582340).to_s))
    ctr = ctr + 1
  end
  puts "Done!  #{ctr} total users set with user identifier"
end