class Customer < ActiveRecord::Base
  
  has_many :reservations
  has_many :courses
  
  validates_format_of :email,:allow_blank=>true,:allow_nil=>true, :with => /^([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})$/i, :message => "Invalid email format"
  validates_format_of :phone,:allow_blank=>true,:allow_nil=>true, :with => /^[\(\)0-9\- \+\.]{10,20}$/ , :message => "Invalid phone format"
  
  # Create the login_info hash with all the parameters you took in
  # Do a find_or_create _by_email for the Customer record
  def self.login(f_name, l_name, contact_via, contact,password, device_name, os_version, app_version, send_deals)  

    if password.nil?
      password = "deepcliff_"+f_name[0,1].upcase+l_name[0,1].upcase+"_"+(Customer.last.id+1).to_s
    end
    
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
          :send_deals=>send_deals,
          :is_password_temp=>true
        }.to_json
    }
    if contact_via == 'email'
      login_info[:email] = contact
      conditions = "email = '#{contact}'"
    else
      login_info[:phone] = contact
      conditions = "phone = '#{contact}'"
    end

    # FInd customer by email, if exists then update attributes
    # If customer does not exist by email, create a new customer record
    c = Customer.find_by_email(login_info[:email])
    if c
      c.update_attributes(login_info)
      return c
    else
      customer = Customer.create(login_info)
      return customer
    end    
  end
  
end







