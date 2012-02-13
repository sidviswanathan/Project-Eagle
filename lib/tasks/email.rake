# Currently the EmailReservatiions do not sync up with the Reservation table
# Once Reservaton table 
desc "Fetch all Email Reservation records rom db, update them in the Reservation table, then delete each record"
task :update_email_reservations => :environment do
  ctr=0
  emails = EmailReservation.all
  emails.each do |email|        
    r = Reservation.find(:all, :conditions => ["date = ? AND time = ? AND golfers = ? AND course_id = ?",email.date,email.time,email.golfers,email.course_id])
    if r
      r.update_attributes :booking_type => 'email' 
      ctr = ctr + 1
      email.delete
    end
  end  
  puts "Done!  Successfully updated the booking type for #{ctr} of #{emails.count} reservation records."
end



