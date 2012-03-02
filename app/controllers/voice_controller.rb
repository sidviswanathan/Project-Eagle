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
      r.Say 'Welcome to Deep Cliff Golf Course', :voice => 'man'
    end
    render :text => response.text
  end
end
