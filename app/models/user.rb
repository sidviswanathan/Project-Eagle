class User < ActiveRecord::Base
  
  has_many :reservations
  belongs_to :course

  validates_presence_of :email
  validates_uniqueness_of :email
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email format"
  
  # Login method for user, creates a User record in database
  # INPUT:   
  # SUCCESS OUTPUT:  
  # FAILURE OUTPUT:  
  
  def self.login(f_name, l_name, email, device_name, os_version, app_version)    
    login_info = {:email=>email, :f_name=>f_name, :l_name=>l_name, :device_name=>device_name, :os_version=>os_version, :app_version=>app_version}
    u = User.find_or_create_by_email(login_info)    
    if u; return u else return nil end
  end
  
end
