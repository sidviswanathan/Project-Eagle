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
        r.update_attributes :booking_type => 'email' 
        ctr = ctr + 1
        email.delete
      end
    end  
    puts "Done!  Successfully updated the booking type for #{ctr} of #{emails.count} reservation records."
  end
  
  # Creates 10 sameple EmailReservation records and corressponding Reservation records
  desc "Fetch all Email Reservation records rom db, update them in the Reservation table, then delete each record"
  task :create_email_reservations => :environment do
    for i in 1..10
      er                    = EmailReservation.new
      r                     = Reservation.new
      r.booking_type        = 'iPhone'
      er.course_id          = r.course_id          = 999
      er.golfers            = r.golfers            = 4
      er.date               = r.date               = '2018-06-'+ '%02d' % i
      er.time               = r.time               = '14:'+ '%02d' % i
      er.confirmation_code  = r.confirmation_code  = String.random_alphanumeric(size=14)
      er.save;r.save
    end      
  end

  # Deletes ALL EmailReservation and Reservation records with course_ird == 999
  desc "Fetch all Email Reservation records rom db, update them in the Reservation table, then delete each record"
  task :delete_reservations => :environment do
    er = EmailReservation.delete_all("course_id = 999")
    r  = Reservation.delete_all("course_id = 999")
  end
  
end

def String.random_alphanumeric(size=14)
  s = ""
  size.times { s << (i = Kernel.rand(62); i += ((i < 10) ? 48 : ((i < 36) ? 55 : 61 ))).chr }
  s
end


