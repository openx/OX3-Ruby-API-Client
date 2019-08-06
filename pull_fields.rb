require 'rubygems'
require 'json'
require 'oauth'
require_relative 'ox3client.rb'
require_relative 'my_config'

email = $cfg_email
password = $cfg_password
consumer_key = $cfg_consumer_key
consumer_secret = $cfg_consumer_secret
realm = $cfg_realm
site_url = $cfg_domain

ox3 = OX3APIClient.new(email, password, site_url, consumer_key, consumer_secret, realm)

puts ox3.get('/report/fields')
