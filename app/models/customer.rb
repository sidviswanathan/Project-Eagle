class Customer < ActiveRecord::Base
  
  has_many :reservations
  has_many :courses
  
  #validates_presence_of :email
  #validates_uniqueness_of :email  
  #validates_uniqueness_of :phone  
  #validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email format"
  #validates_format_of :phone, :with => /^[\(\)0-9\- \+\.]{10,20}$/ , :message => "Invalid phone format"
  

  def self.login(f_name, l_name, contact_via, email,phone,password, device_name, os_version, app_version, send_deals)  
         
    login_info = {
        :email               => email, 
        :f_name              => f_name, 
        :l_name              => l_name, 
        :name                => f_name+" "+l_name,
        :password            => password,
        :contact_via         => contact_via,
        :phone               => phone,
        :data                => {
            :device_name=>device_name,
            :os_version=>os_version,
            :app_version=>app_version
        }.to_json,
        :prefs               => {
          :send_deals=>send_deals
        }.to_json
    }
    conditions = []
    if !phone.nil? or phone != ""
      conditions.push("phone = '#{phone}'")
    end
    if !email.nil? or email != ""
      conditions.push("email = '#{email}'")
    end
    
    c = Customer.find(:all, :conditions => conditions.join(" or "))
    if c.length == 0
      c = Customer.create(login_info)
    else
      c = c[0]
    end
      
    c.save
    return c
  end
  
  
end
