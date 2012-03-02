require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'twiliolib'
require 'twilio-ruby'
require 'pp'

class VoiceController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def recieve
    response = Twilio::TwiML::Response.new do |r|
      d = DataStore.create({:name=>"call_"+params[:CallSid],:data=>{}.to_json})
      greeting = 'Welcome to Deep Cliff Golf Course.  To book a Tee Time, press 1.  To speak with the course, press 2'
      r.Gather :action => "/voice/options" do |d|
        d.Say greeting, :voice => 'man'
      end

    end
    render :text => response.text
  end
  
  def options
    response = Twilio::TwiML::Response.new do |r|

      if params[:Digits] == "1"
        r.Say "Good Choice, please say a day within the next 2 weeks, for example tuesday or next tuesday!", :voice => 'man'
        r.Record :action => "/voice/getdate", :transcribe => true, :timeout => "3"
      else
        r.Say "Too bad, you lose", :voice => 'woman'
      end
    end
    render :text => response.text
  end
  
  def getdate
    d = DataStore.find_by_name("call_"+params[:CallSid])
    data = JSON.parse(d.data)
    data["day"]  = params[:TranscriptionText]
    d.data = data.to_json
    d.save
    response = Twilio::TwiML::Response.new do |r|
      r.Say "You picked "+data["day"]+" now say a time such as 10:15 and we'll pick the nearest available time", :voice => 'man'
      r.Record :action => "/voice/gettime", :transcribe => true, :timeout => "3"
    end
    render :text => response.text
    
  end
  
  def gettime
    d = DataStore.find_by_name("call_"+params[:CallSid])
    data = JSON.parse(d.data)
    data["time"] = params[:TranscriptionText]
    d.data = data.to_json
    d.save
    response = Twilio::TwiML::Response.new do |r|
      r.Say "How many golfers are in your party on "+data["day"]+" at "+data["time"], :voice => 'man'
      r.Record :action => "/voice/getgolfers", :transcribe => true, :timeout => "3"
    end
    render :text => response.text
    
  end
  def gettime
    d = DataStore.find_by_name("call_"+params[:CallSid])
    data = JSON.parse(d.data)
    data["golfers"] = params[:TranscriptionText].to_i
    d.data = data.to_json
    d.save
    response = Twilio::TwiML::Response.new do |r|
      r.Say "Please confirm your slot for "+data["golfers"].to_s+" on "+data["day"]+" at "+data["time"]+" by saying Yes or No ..", :voice => 'man'
      r.Record :action => "/voice/confirm", :transcribe => true, :timeout => "3"
    end
    render :text => response.text
    
  end
  
  def confirm
    yesno = params[:TranscriptionText]
    response = Twilio::TwiML::Response.new do |r|
      if yesno == 'yes'
        r.Say "Thanks for your business, your tee time has been reserved!", :voice => 'man'
      else
        r.Say "Would you like to try again? Say Golfers, Time, or Date to change a variable", :voice => 'man'
      end

    end
    render :text => response.text
    
  end
end
