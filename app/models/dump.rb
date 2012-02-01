require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'lib/api/fore.rb'
require "net/http"
require "net/https"

class Dump < ActiveRecord::Base
  ADD_TASK_HOST                         = 'http://dump-them.appspot.com'
  ADD_TASK_URI                          = '/schedule/'
  def self.schedule(did,eta)
    query = "#{ADD_TASK_URI}perform_reminder?key=#{did}&dt=#{eta}"
    
    url = URI.parse(ADD_TASK_HOST)
    http = Net::HTTP.new(url.host, url.port)
    http.use_ssl = false
    headers = {}
    puts "hello schedule_mailing"
    response = http.get(query, headers)
    response2 = http.post(query, headers)
    return response
  end
end
