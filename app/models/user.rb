class User < ActiveRecord::Base
  
  has_many :reservations
  belongs_to :course

  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email format"
  
  # Login method for user, creates a User record
  # INPUT:  
  # OUTPUT: 
  
  def login()
    u = User.find_or_create_by_email(fName, lName, email)
    
    login_info = {:email=>'sid.viswanathan@gmail.com', :first_name=>'Sid', :last_name=>'Viswanathan'}
    user = User.find_or_create_by_email(info)
    
    # Create or find user record (must build for the case wehre user deletes app and reinstalls it and signs in again)
    # Return success object or failure object
    return
  end
  
end
