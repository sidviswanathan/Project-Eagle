module Twilio

  require 'twiliolib'
  require 'pp'
  
  H = { :a => 'aayy',
        :b => 'bee',
        :c => 'see',
        :d => 'dee',
        :e => 'ee',
        :f => 'ef',
        :g => 'gee',
        :h => 'aych',
        :i => 'eye',
        :j => 'jay',
        :k => 'kay',
        :l => 'el',
        :m => 'em',
        :n => 'en',
        :o => 'oh',
        :p => 'pee',
        :q => 'cue',
        :r => 'are',
        :s => 'ess',
        :t => 'tee',
        :u => 'you',
        :v => 'vee',
        :w => 'double u',
        :x => 'ex',
        :y => 'why',
        :z => 'zee'
      }
  
  # ===========================================================================
  # Initiate Twilio keys and variables
  # ===========================================================================
  
  # Twilio REST API version
  API_VERSION = '2010-04-01'

  # Twilio AccountSid and AuthToken
  ACCOUNT_SID = 'ACc6377a248c5300434e40041d2bd1b9c3'
  ACCOUNT_TOKEN = '8fcabbf06e89b828c7d5b59fb583e38a'

  # Outgoing Caller ID previously validated with Twilio
  CALLER_ID = '510-304-1372'
  
  def make_twilio_call(params)
    
    # Create a Twilio REST account object using your Twilio account ID and token
    account = Twilio::RestAccount.new(ACCOUNT_SID, ACCOUNT_TOKEN)
    
    # ===========================================================================
    # Initiate a new outbound call to 301-806-3772
    # ===========================================================================
    
    say = create_say_string(params)
  
    d = {
        'From' => CALLER_ID,
        'To' => '301-806-3772',
        'Url' => "http://projecteagle.heroku.com/reservations/place_automated_call?SAY=#{say}"
        }
    resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/Calls",
        'POST', d)
    resp.error! unless resp.kind_of? Net::HTTPSuccess
    puts "code: %s\nbody: %s" % [resp.code, resp.body]
    
  end  
  
  #IMPLEMENT
  def create_say_string(params)    
    first_name_say = convert_to_letters(params["fName"])
    last_name_say = convert_to_letters(params["lname"])
    date = params["date"].strftime('%A'+' '+'%B'+' '+'%d')
    say = "This is a tee time reservation on #{date} at #{params["tee_slot"]} for #{params["fName"]} #{params["lname"]} for #{params["golfers"]} golfers, that's #{date} at #{params["tee_slot"]} for #{params["golfers"]} golfers for #{params["fName"]} #{params["lname"]} first name #{first_name_say} last name #{last_name_say}".split(' ').join('+')      
    return say
  end
  
  def convert_to_letters(string)
    name = ""
    for i in 0..string.length-1
      letter = string[i..i].downcase.to_sym
      if name == ""
        name = H[letter]  
      else
        name = name+'+'+H[letter]  
      end    
    end
    return name
  end    
  
  #  # ===========================================================================
  #  # 2. Get a list of recent completed calls (i.e. Status = 2)
  #  #    uses a HTTP GET
  #  d = { 'Status' => 2 }
  #  resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/Calls",
  #      'GET', d)
  #  resp.error! unless resp.kind_of? Net::HTTPSuccess
  #  puts "code: %s\nbody: %s" % [resp.code, resp.body]
  # 
  #  # ===========================================================================
  #  # 3. Get a list of recent notification log entries
  #  #    uses a HTTP GET
  #  resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/\
  #  Notifications", 'GET')
  #  resp.error! unless resp.kind_of? Net::HTTPSuccess
  #  puts "code: %s\nbody: %s" % [resp.code, resp.body]
  # 
  #  # ===========================================================================
  #  # 4. Get a list of audio recordings for a certain call
  #  #    uses a HTTP GET
  #  d = { 'CallSid' => 'CA5d44cc11756367a4c54e517511484900' }
  #  resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/Recordings",
  #      'GET', d)
  #  resp.error! unless resp.kind_of? Net::HTTPSuccess
  #  puts "code: %s\nbody: %s" % [resp.code, resp.body]
  # 
  #  # ===========================================================================
  #  # 5. Delete a specific recording
  #  #    uses a HTTP DELETE, no response is returned when using DLETE
  #  resp = account.request( \
  #      "/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/Recordings/\
  #  RE7b22d733d3e730d234e94242b9697cae", 'DELETE')
  #  puts "code: %s" % [resp.code]
  # 
  #  # ===========================================================================
  #  # 6. Send an SMS Message to 415-555-1212
  #  #    uses a HTTP POST, and a new variable t for the information (because it needs "Body")
  #  t = {
  #      'From' => CALLER_ID,
  #      'To'   => '415-555-1212',
  #      'Body' => "Hello, world. This is a text from Twilio using Ruby!"
  #  }
  #  resp = account.request("/#{API_VERSION}/Accounts/#{ACCOUNT_SID}/SMS/Messages",
  #        "POST", t)
 
end