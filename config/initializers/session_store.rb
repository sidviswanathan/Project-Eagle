# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_eagle_session',
  :secret      => '7609aef9d8d970aa563d0cb90fc7c7609b9917b504603e6e5a8608e9ac4a56030312f911a2405e7552b8dd65eb06c50beec1703ee506286e331286d68bb54411'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
