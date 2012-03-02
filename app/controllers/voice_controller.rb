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
      greeting = 'Welcome to Deep Cliff Golf Course.  To book a Tee Time, press 1.  To speak with the course, press 2'
      r.Gather do |d|
        d.Say greeting, :voice => 'man'
      end

    end
    render :text => response.text
  end
end
