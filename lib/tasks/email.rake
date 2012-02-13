namespace :email do

  # Currently the EmailReservatiions do not sync up with the Reservation table
  # Once Reservaton table has live bookings for Deep CLiff,  
  desc "Fetch all Email Reservation records rom db, update them in the Reservation table, then delete each record"
  task :update_email_reservations => :environment do
    ctr=0
    emails = EmailReservation.all
    emails.each do |email|        
      r = Reservation.find(:first, :conditions => ["date = ? AND time = ? AND golfers = ? AND course_id = ?",email.date,email.time,email.golfers,email.course_id])
      if r
        r.update_attribute :booking_type => 'email' 
        ctr = ctr + 1
        email.delete
      end
    end  
    puts "Done!  Successfully updated the booking type for #{ctr} of #{emails.count} reservation records."
  end
  
  # Creates 10 sameple EmailReservation records and corressponding Reservation records
  desc "Fetch all Email Reservation records rom db, update them in the Reservation table, then delete each record"
  task :create_email_reservations => :environment do
  end

  # Deletes the 10 created EmailReservation records and corressponding Reservation records
  desc "Fetch all Email Reservation records rom db, update them in the Reservation table, then delete each record"
  task :delete_email_reservations => :environment do
  end
  
end

def String.random_alphanumeric(size=14)
  s = ""
  size.times { s << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
  s
end


