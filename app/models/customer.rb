class Customer < ActiveRecord::Base
  
  has_many :reservations
  has_many :courses
  
  #validates_presence_of :email
  #validates_uniqueness_of :email  
  #validates_uniqueness_of :phone  
  #validates_format_of :email, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email format"
  #validates_format_of :phone, :with => /^[\(\)0-9\- \+\.]{10,20}$/ , :message => "Invalid phone format"
  

  def self.login(f_name, l_name, contact_via, contact,password, device_name, os_version, app_version, send_deals)  
         
    login_info = { 
        :f_name              => f_name, 
        :l_name              => l_name, 
        :name                => f_name+" "+l_name,
        :password            => password,
        :contact_via         => contact_via,
        :data                => {
            :device_name=>device_name,
            :os_version=>os_version,
            :app_version=>app_version
        }.to_json,
        :prefs               => {
          :send_deals=>send_deals
        }.to_json
    }
    if contact_via == 'email'
      login_info[:email] = contact
      conditions = "email = '#{contact}'"
    else
      login_info[:phone] = contact
      conditions = "phone = '#{contact}'"
    end
    if login_info[:password].nil?
      login_info[:password] = login_info[:f_name]+login_info[:l_name]
    end
    c = Customer.find(:all, :conditions => conditions)
    if c.length == 0
      c = Customer.create(login_info)
    else
      c = c[0]
    end
      
    return c
  end
  
  
end
