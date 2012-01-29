require 'pp'
require 'xmlsimple'
require 'json'
require 'date'
require 'lib/api/fore.rb'


class Course < ActiveRecord::Base
  
  has_many :users
  has_many :reservations

  
end
