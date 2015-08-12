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
puts ox3.get('/site')

# Create site
site = ox3.post('/site',
  {'name' => "SiteName ##{Random.rand(1000)}",
   'url' => 'http://www.sample.com',
   'account_uid' => '60000028-accf-fff1-8123-0c9a66', # uid of your publisher account
   'status' => 'Active'}
)
puts site

# Update site
site_uid = '20000001-e000-fff1-8123-0c9a66'
site = ox3.put("/site/#{site_uid}",
  {'name' => "Updated Name for Site #{site_uid}", 'url' => 'http://www.sample.com'}
)
puts site

# Check that the site's name was updated
site = JSON.parse(ox3.get("/site/#{site_uid}"))
puts site
puts site[0]['name']

