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
      d = DataStore.create({:name=>"call_"+params[:CallSid],:data=>{"day"=>"monday","time"=>"10:15","golfers"=>"2"}.to_json})
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
        r.Say "Now say something like next tuesday at 2pm for 4 golfers ", :voice => 'man'
        r.Record :action => "/voice/getdate", :transcribeCallback => '/voice/transcribe_callback', :timeout => "3"
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
    d.data = data.to_json
    d.save
  end
  
  def getdate
    d = DataStore.find_by_name("call_"+params[:CallSid])
    data = JSON.parse(d.data)

    response = Twilio::TwiML::Response.new do |r|
      r.Say "Please wait about a minute while we process your request", :voice => 'man'
      r.Pause :length=>90
      r.Redirect "/voice/process"
    end
    render :text => response.text
    
  end
  
  def process
    d = DataStore.find_by_name("call_"+params[:CallSid])
    data = JSON.parse(d.data)
    response = Twilio::TwiML::Response.new do |r|
      r.Say "Please confirm your slot for ", :voice => 'man'
      r.Play data["voice"]
      r.Say "Please say yes or no "
    end
    render :text => response.text
    
  end
  def getgolfers
    d = DataStore.find_by_name("call_"+params[:CallSid])
    data = JSON.parse(d.data)

    response = Twilio::TwiML::Response.new do |r|
      r.Say "Please confirm your slot for "+data["golfers"].to_s+" on "+data["day"]+" at "+data["time"]+" by saying Yes or No ..", :voice => 'man'
      r.Record :action => "/voice/confirm", :transcribeCallback => '/voice/transcribe_callback?save=golfers', :timeout => "3"
    end
    render :text => response.text
    
  end
  
  def confirm
    d = DataStore.find_by_name("call_"+params[:CallSid])
    data = JSON.parse(d.data)
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
