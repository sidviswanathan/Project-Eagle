desc "Fetch all Email Reservation records rom db, update them in the Reservation table, then delete each record"
task :update_email_reservations => :environment do
  emails = EmailReservation.all
  
  emails = User.find_each(:select => "date, time, golfers, course_id") do |email|
    
    email.destroy
  end
  
  
  pr = PendingResult.find_each(:select => "id") do |prs|
    puts prs.id
  end
  
  
  ctr = 0
  users = User.all
  users.each do |user|
    user.update_attribute(:user_identifier, Digest::MD5.hexdigest((Time.now.to_s) + rand(1542395823049582340).to_s))
    ctr = ctr + 1
  end
  puts "Done!  #{ctr} total users set with user identifier"
end