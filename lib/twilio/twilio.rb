module Twilio

  require 'twiliolib'

  # Twilio REST API version
  API_VERSION = '2010-04-01'

  # Twilio AccountSid and AuthToken
  ACCOUNT_SID = 'ACc6377a248c5300434e40041d2bd1b9c3'
  ACCOUNT_TOKEN = '8fcabbf06e89b828c7d5b59fb583e38a'

  # Outgoing Caller ID previously validated with Twilio
  CALLER_ID = '551-206-5838';

  # Create a Twilio REST account object using your Twilio account ID and token
  account = Twilio::RestAccount.new(ACCOUNT_SID, ACCOUNT_TOKEN)

  # ===========================================================================
  # 1. Initiate a new outbound call to 301-806-3772
  #    uses a HTTP POST
  d = {
      'From' => CALLER_ID,
      'To' => '301-806-3772',
      'Url' => 'http://demo.twilio.com/welcome',
  }
  resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/Calls",
      'POST', d)
  resp.error! unless resp.kind_of? Net::HTTPSuccess
  puts "code: %s\nbody: %s" % [resp.code, resp.body]

  # ===========================================================================
  # 2. Get a list of recent completed calls (i.e. Status = 2)
  #    uses a HTTP GET
  d = { 'Status' => 2 }
  resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/Calls",
      'GET', d)
  resp.error! unless resp.kind_of? Net::HTTPSuccess
  puts "code: %s\nbody: %s" % [resp.code, resp.body]

  # ===========================================================================
  # 3. Get a list of recent notification log entries
  #    uses a HTTP GET
  resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/\
  Notifications", 'GET')
  resp.error! unless resp.kind_of? Net::HTTPSuccess
  puts "code: %s\nbody: %s" % [resp.code, resp.body]

  # ===========================================================================
  # 4. Get a list of audio recordings for a certain call
  #    uses a HTTP GET
  d = { 'CallSid' => 'CA5d44cc11756367a4c54e517511484900' }
  resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/Recordings",
      'GET', d)
  resp.error! unless resp.kind_of? Net::HTTPSuccess
  puts "code: %s\nbody: %s" % [resp.code, resp.body]

  # ===========================================================================
  # 5. Delete a specific recording
  #    uses a HTTP DELETE, no response is returned when using DLETE
  resp = account.request( \
      "/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/Recordings/\
  RE7b22d733d3e730d234e94242b9697cae", 'DELETE')
  puts "code: %s" % [resp.code]

  # ===========================================================================
  # 6. Send an SMS Message to 415-555-1212
  #    uses a HTTP POST, and a new variable t for the information (because it needs "Body")
  t = {
      'From' => CALLER_ID,
      'To'   => '415-555-1212',
      'Body' => "Hello, world. This is a text from Twilio using Ruby!"
  }
  resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/SMS/Messages",
        "POST", t)

end