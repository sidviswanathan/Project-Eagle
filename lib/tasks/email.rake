desc "Fetch all Email Reservation records rom db, update them in the Reservation table, then delete each record"
task :update_email_reservations => :environment do
  ctr=0
  emails = EmailReservation.all
  emails.each do |email|
    
        
    r = Reservation.find(:all, :conditions => ["date = ? AND time = ? AND golfers = ? AND course_id = ?",'2012-02-01','12:44','3','1'])
    
    
    if r
      r.update_attributes :booking_type => 'email' 
      ctr = ctr + 1
    end
  end  
  email.destroy
  puts "Done!  Successfully updated the booking type for #{ctr} of #{emails.count} reservation records."
end



