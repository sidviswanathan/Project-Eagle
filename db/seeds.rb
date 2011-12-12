# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

u = User.find_by_email('carlcwheatey@gmail.com')
if u == nil
  u.email = 'carlcwheatey@gmail.com'
  u.f_name = 'Carl'
  u.l_name = 'Wheatley'
  u.device_name = 'iPhone'
  u.os_version = '5.0'
  u.app_version = '1.0'
  
  if !u.save
    puts 'user seed failed!'
  end
end