require 'rubygems'
require 'json'
require 'oauth'
require_relative 'ox3client.rb'


email = ''
password = ''
consumer_key = ''
consumer_secret = ''
realm = ''
site_url = ''

ox3 = OX3APIClient.new(email, password, site_url, consumer_key, consumer_secret, realm)
puts ox3.get('/a/site')

site = ox3.post('/a/site/12345',
  {'id' => 12345, 'name' => 'SiteName', 'url' => 'http://www.sample.com', 'status' => 'Active'}
)
puts site
site = JSON.parse(ox3.get('/a/site/12345'))
puts site
puts site['name']
