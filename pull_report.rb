require 'rubygems'
require 'json'
require 'oauth'
require_relative 'ox3client.rb'

email = 'email@domain.com'
password = 'password'
consumer_key = '123qwe123qwe123qwe123qwe'
consumer_secret = '456zxcv456zxcv456zxc45zc'
realm = 'ui_realm'
site_url = 'ui_domain'

ox3 = OX3APIClient.new(email, password, site_url, consumer_key, consumer_secret, realm)

settings = {"startDate":20190615,"endDate":20190616,"attributes":[{"id":"publisherCurrency"},{"id":"publisherSiteName"},{"id":"publisherAdUnitName"}],"metrics":[{"id":"marketRequests"},{"id":"exchangeFills"},{"id":"marketImpressions"},{"id":"marketPublisherRevenue"}]}

puts ox3.post('/report/', settings)
