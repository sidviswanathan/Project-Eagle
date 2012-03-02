require 'pp'
require 'json'
require 'apns'
require 'xmlsimple'
require 'date'
require 'chronic'
require 'twiliolib'
require 'twilio-ruby'
require 'pp'

class VoiceController < ApplicationController
  skip_before_filter :verify_authenticity_token
  def recieve
    response = Twilio::TwiML::Response.new do |r|
      d = DataStore.create({:name=>"call_"+params[:CallSid],:data=>{"text"=>"monday","voice"=>"10:15"}.to_json})
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
        r.Say "Now say something like .. next tuesday at 2pm for 4 golfers ", :voice => 'man'
        r.Record :action => "/voice/getdate", :transcribeCallback => '/voice/transcribe_callback'
      else
        r.Say "Too bad, you lose", :voice => 'woman'
      end
    end
    render :text => response.text
  end
  
  def transcribe_callback
    d = DataStore.find_by_name("call_"+params[:CallSid])
    data = JSON.parse(d.data)
    data["text"]  = params[:TranscriptionText]
    data["voice"] = params[:RecordingUrl]
    
    split = data["text"].split(" ")
    
    golfers = "2"
    xdate = nil
    time = "2"
    
    days = ["monday","tuesday","wednesday","thursday","friday","saturday","sunday"]
    nexter = false
    count = 0
    substring = ""
    split.each do |s|
      substring += s+" "
      date = Chronic.parse(s)
      if !date.nil?
        xdate = date
      end
      if s == 'next'
        nexter = true
      end
    end
    reverse = split.reverse
    
    reverse.each do |r|
      golfers = r.to_i
      break if !golfers.nil?
    end
    
    golfers = golfers.to_s
    
    puts golfers
    puts date.to_s
    
    d.data = data.to_json
    d.save
  end
  
  def getdate
    d = DataStore.find_by_name("call_"+params[:CallSid])
    data = JSON.parse(d.data)

    response = Twilio::TwiML::Response.new do |r|
      r.Say "Please wait about 15 seconds while we process your request", :voice => 'man'
      r.Pause :length=>15
      r.Redirect "/voice/gettime"
    end
    render :text => response.text
    
  end
  
  def gettime
    d = DataStore.find_by_name("call_"+params[:CallSid])
    data = JSON.parse(d.data)
    response = Twilio::TwiML::Response.new do |r|
      greeting = "Please confirm your slot for "+data["text"]+" by pressing 1 for yes or 2 for no"
            
      r.Gather :action => "/voice/book" do |d|
        d.Say greeting, :voice => 'man'
      end
      
    end
    render :text => response.text
  end
  
  def book
    response = Twilio::TwiML::Response.new do |r|
      greeting = "Thanks for your business, have a good day!"
      r.Say greeting, :voice => 'man'
    end
    render :text => response.text
  end

end
