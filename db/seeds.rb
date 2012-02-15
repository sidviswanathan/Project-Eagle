# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#   
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Major.create(:name => 'Daley', :city => cities.first)

u = User.new
u.email = 'carlcwheatey@gmail.com'
u.f_name = 'Carl'
u.l_name = 'Wheatley'
u.device_name = 'iPhone'
u.os_version = '5.0'
u.app_version = '1.0'

if !u.save
  puts 'user seed failed!'
end

#m = Manager.create({:email => "eagle@presstee.com", :password => "eagle1", :courses => [].to_json})

m = Manager.new
    m.email      = "eagle@presstee.com"
    m.password   = "eagle1"
    m.courses    = {"list"=>[1],"acl"=>{1=>["destroy","manage","admin"]}}.to_json
    m.acl        = ['create','destroy','manage','admin'].to_json
    m.save
    

c = Course.new
c.name = "Deep Cliff"
c.api = "fore"
c.api_course_id = "1987654"
c.fee_matrix = {
  "split" => [14,16],
  "holidays" => [1,360],
  "public" => {
    "weekday" => [28,21,18],
    "weekend" => [38,28,22]},
  "member" => {
    "weekday" => [21,17,15],
    "weekend" => [31,22,17]}
}.to_json

c.info = {
  "title_short" => "Deep Cliff",
  "title" => "Deep Cliff Golf Course",
  "url" => "http://www.playdeepcliff.com/",
  "phone" => "(408) 253-5357",
  "address" => {
    "city" => "Cupertino",
    "state" => "CA",
    "street" => "10700 Club House Ln",
  },
  "managers" => ["eagle@presstee.com"],
  "logo" => "/images/tlogo.png",
  "gallery" => ["/images/holes/hole1.png","/images/holes/hole2.png","/images/holes/hole3.png","/images/holes/hole4.png","/images/holes/hole5.png","/images/holes/hole5.png","/images/holes/hole6.png","/images/holes/hole7.png","/images/holes/hole8.png","/images/holes/hole9.png","/images/holes/hole10.png","/images/holes/hole11.png","/images/holes/hole12.png","/images/holes/hole13.png","/images/holes/hole14.png","/images/holes/hole15.png","/images/holes/hole16.png","/images/holes/hole17.png","/images/holes/hole18.png"]
}.to_json
c.mobile_domain = "http://m.deepclifftv.com/"
c.web_domain = "http://www.deepclifftv.com/"
c.future_dates = {
  "template" => [{"p"=>28,"q"=>"4","t"=>"08:04"},{"p"=>28,"q"=>"4","t"=>"08:12"},{"p"=>28,"q"=>"4","t"=>"08:20"},{"p"=>28,"q"=>"4","t"=>"08:28"},{"p"=>28,"q"=>"4","t"=>"08:36"},{"p"=>28,"q"=>"4","t"=>"08:44"},{"p"=>28,"q"=>"4","t"=>"08:52"},{"p"=>28,"q"=>"4","t"=>"09:00"},{"p"=>28,"q"=>"4","t"=>"09:08"},{"p"=>28,"q"=>"4","t"=>"09:16"},{"p"=>28,"q"=>"4","t"=>"09:24"},{"p"=>28,"q"=>"4","t"=>"09:32"},{"p"=>28,"q"=>"4","t"=>"09:40"},{"p"=>28,"q"=>"4","t"=>"09:48"},{"p"=>28,"q"=>"4","t"=>"09:56"},{"p"=>28,"q"=>"4","t"=>"10:04"},{"p"=>28,"q"=>"4","t"=>"10:12"},{"p"=>28,"q"=>"4","t"=>"10:20"},{"p"=>28,"q"=>"4","t"=>"10:28"},{"p"=>28,"q"=>"4","t"=>"10:36"},{"p"=>28,"q"=>"4","t"=>"10:44"},{"p"=>28,"q"=>"4","t"=>"10:52"},{"p"=>28,"q"=>"4","t"=>"11:00"},{"p"=>28,"q"=>"4","t"=>"11:08"},{"p"=>28,"q"=>"4","t"=>"11:16"},{"p"=>28,"q"=>"4","t"=>"11:24"},{"p"=>28,"q"=>"4","t"=>"11:32"},{"p"=>28,"q"=>"4","t"=>"11:40"},{"p"=>28,"q"=>"4","t"=>"11:48"},{"p"=>28,"q"=>"4","t"=>"11:56"},{"p"=>28,"q"=>"4","t"=>"12:04"},{"p"=>28,"q"=>"4","t"=>"12:12"},{"p"=>28,"q"=>"4","t"=>"12:20"},{"p"=>28,"q"=>"4","t"=>"12:28"},{"p"=>28,"q"=>"4","t"=>"12:36"},{"p"=>28,"q"=>"4","t"=>"12:44"},{"p"=>28,"q"=>"4","t"=>"12:52"},{"p"=>28,"q"=>"4","t"=>"13:00"},{"p"=>28,"q"=>"4","t"=>"13:08"},{"p"=>28,"q"=>"4","t"=>"13:16"},{"p"=>28,"q"=>"4","t"=>"13:24"},{"p"=>28,"q"=>"4","t"=>"13:32"},{"p"=>28,"q"=>"4","t"=>"13:40"},{"p"=>28,"q"=>"4","t"=>"13:48"},{"p"=>28,"q"=>"4","t"=>"13:56"},{"p"=>21,"q"=>"4","t"=>"14:04"},{"p"=>21,"q"=>"4","t"=>"14:12"},{"p"=>21,"q"=>"4","t"=>"14:20"},{"p"=>21,"q"=>"4","t"=>"14:28"},{"p"=>21,"q"=>"4","t"=>"14:36"},{"p"=>21,"q"=>"4","t"=>"14:44"},{"p"=>21,"q"=>"4","t"=>"14:52"},{"p"=>21,"q"=>"4","t"=>"15:00"},{"p"=>21,"q"=>"4","t"=>"15:08"},{"p"=>21,"q"=>"4","t"=>"15:16"},{"p"=>21,"q"=>"4","t"=>"15:24"},{"p"=>21,"q"=>"4","t"=>"15:32"},{"p"=>21,"q"=>"4","t"=>"15:40"},{"p"=>21,"q"=>"4","t"=>"15:48"},{"p"=>21,"q"=>"4","t"=>"15:56"},{"p"=>18,"q"=>"4","t"=>"16:04"},{"p"=>18,"q"=>"4","t"=>"16:12"},{"p"=>18,"q"=>"4","t"=>"16:20"},{"p"=>18,"q"=>"4","t"=>"16:28"},{"p"=>18,"q"=>"4","t"=>"16:36"},{"p"=>18,"q"=>"4","t"=>"16:44"},{"p"=>18,"q"=>"4","t"=>"16:52"},{"p"=>18,"q"=>"4","t"=>"17:00"}],
  "taken" => {}
}.to_json
c.save