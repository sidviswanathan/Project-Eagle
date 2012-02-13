class Course < ActiveRecord::Base  
  has_many :users
  has_many :reservations
  
  def self.default
    c = Course.new
    c.name = "Default Hills"
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
      "title_short" => "Default Hills",
      "title" => "Default Hills Golf Course",
      "url" => "http://www.presstee.com/",
      "phone" => "(408) 253-5357",
      "address" => {
        "city" => "Default Ville",
        "state" => "CA",
        "street" => "9999 Default Rd",
      },
      "logo" => "/images/tlogo.png",
      "gallery" => ["/images/holes/hole1.png","/images/holes/hole2.png","/images/holes/hole3.png","/images/holes/hole4.png","/images/holes/hole5.png","/images/holes/hole5.png","/images/holes/hole6.png","/images/holes/hole7.png","/images/holes/hole8.png","/images/holes/hole9.png","/images/holes/hole10.png","/images/holes/hole11.png","/images/holes/hole12.png","/images/holes/hole13.png","/images/holes/hole14.png","/images/holes/hole15.png","/images/holes/hole16.png","/images/holes/hole17.png","/images/holes/hole18.png"]
    }.to_json
    c.mobile_domain = "http://m.presstee.com/"
    c.web_domain = "http://www.presstee.com/"
    c.future_dates = {}.to_json
    return c
  end
end
