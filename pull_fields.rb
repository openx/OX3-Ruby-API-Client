require 'rubygems'
require 'json'
require 'oauth'
require_relative 'ox3client.rb'

email = 'email@domain.com'
password = 'password'
consumer_key = '123qwer123qwe123qwe123qwe123qwe'
consumer_secret = '456zxc567cxz567xzc567zxc567czx'
realm = 'ui_realm'
site_url = 'ui_domain'

ox3 = OX3APIClient.new(email, password, site_url, consumer_key, consumer_secret, realm)

puts ox3.get('/report/fields')
