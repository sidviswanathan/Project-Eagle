require 'pp'

class User < ActiveRecord::Base
  
  has_many :reservations
  has_many :courses
  
  validates_presence_of :email
  validates_uniqueness_of :email  
  validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email format"
  
  # Login method for user, creates a User record in database
  # INPUT: User.login("Sid","Viswanathan","sid@gmail.com","iPhone","5.0","1.0")   
  # OUTPUT: #<User id: 1, email: "sid@gmail.com", f_name: "Sid", l_name: "Viswanathan", device_name: "iPhone", os_version: "5.0", app_version: "1.0", created_at: datetime, updated_at: datetime>   
  
  def self.login(f_name, l_name, email, device_name, os_version, app_version)        
    login_info = {:email=>email, :f_name=>f_name, :l_name=>l_name, :device_name=>device_name, :os_version=>os_version, :app_version=>app_version}
    u = User.find_or_create_by_email(login_info) 
    if u.save; return u else return nil end
  end
  
end
