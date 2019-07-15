require 'oauth'
require 'yaml'

class OX3APIClient < OAuth::Consumer
  
  def initialize(email, password, site_url, consumer_key, consumer_secret, realm, 
    version='v2', sso_domain='sso.openx.com', callback='oob', scheme='https', debug=false)
    
    @version, @callback, @site, @debug = version, callback, site_url, debug
    @site = @site.end_with?('/') ? @site.chop : @site
    
    super(consumer_key, consumer_secret, {
      :http_method => :post,
      :scheme => :header,
      :oauth_version => "1.0",
      :signature_method => "HMAC-SHA1",
      :site => @site,
      :request_token_url => scheme + '://' + sso_domain + '/api/index/initiate',
      :access_token_url => scheme + '://' + sso_domain + '/api/index/token',
      :authorize_path => scheme + '://' + sso_domain + '/login/process',
      :realm => realm
    })
    
    # Step 1. Fetch temporary request token.
    fetch_request_token
    
    # Step 2. Log in to SSO server and authorize token.
    authorize_token(email, password)
    
    # Step 3. Swap temporary request token for permanent access token.
    fetch_access_token
    
    # Step 4. Validate your access token.
    validate_session
  end

################################################################################################################
  def get_access_token
    @acccess_token.token
  end

  def perform_request
    http = self.create_http(@site)
    http.open_timeout =  5 * 60
    http.read_timeout = 15 * 60
    params = Hash.new
    params['Content-Type'] = 'application/json'
    params['Cookie'] = 'openx3_access_token=' + @acccess_token.token + '; domain=' + get_domain + '; path=/'
    prefix = "/ox/4.0"
    response = http.request yield prefix, params
    response.body
  end

  def get(path)
    perform_request do |prefix, params|
      self.create_http_request(
        :get, 
        prefix + path, 
        params
      )
    end
  end
  
  def post(path, body = {})
    if body.is_a?(Hash)
      body = JSON.dump(body)
    end
    perform_request do |prefix, params|
      self.create_http_request(
        :post, 
        prefix + path,
        body,
        params
      )
    end
  end
  
  def put(path, body = {})
    if body.is_a?(Hash)
      body = JSON.dump(body)
    end
    perform_request do |prefix, params|
      self.create_http_request(
        :put, 
        prefix + path,
        body,
        params
      )
    end
  end
  
  def delete(path)
    perform_request do |prefix, params|
      self.create_http_request(
        :delete, 
        prefix + path, 
        params
      )
    end
  end
  
  def logoff
    get "/login/logout"
  end
################################################################################################################

private
  def fetch_request_token
    @request_token = self.get_request_token(
      {:oauth_callback => @callback}, 
      {'Content-Type' => 'application/x-www-form-urlencoded'}
    )
    if @debug
      puts YAML::dump(@request_token)
    end
  end
  
  def authorize_token(email, password)
    authorize = self.request(:post,  self.authorize_path, nil, 
      {:oauth_token => @request_token.token, :oauth_callback => @callback},
      {:email => email, :password => password, :oauth_token => @request_token.token},
      {'Content-Type' => 'application/x-www-form-urlencoded'}
    )
    if authorize.code.to_s == '200'
      response = authorize
    else
      response = self.request(:post, authorize.header['Location'], nil, 
        {:oauth_token => @request_token.token, :oauth_callback => @callback}, nil, 
        {
          'Content-Type' => 'application/x-www-form-urlencoded',
          'Cookie' => authorize.get_fields('set-cookie')[0],
        }
      )
    end
    if @debug
      puts YAML::dump(response)
    end
    @oauth_verifier = parse_tokens(response.body)[:oauth_verifier]
  end
  
  def fetch_access_token
    @acccess_token = @request_token.get_access_token(
      {:oauth_verifier => @oauth_verifier, :oauth_token => @request_token.token, :oauth_callback => @callback},
      {'Content-Type' => 'application/x-www-form-urlencoded'}
    )
    if @debug
      puts YAML::dump(@acccess_token)
    end
  end
  
  def validate_session
=begin
    path = "/ox/4.0/session"
    method = :get
    response = self.request(method.to_sym, @site + path, nil, {}, nil,
      {
        'Content-Type' => 'application/json',
        'Cookie' => 'openx3_access_token=' + @acccess_token.token + '; domain=' + get_domain + '; path=/'
      }
    )
=end
    response = perform_request do |prefix, params|
      self.create_http_request(
        :get, 
        prefix + "/session",
        nil,
        params
      )
    end
    if @debug
      puts YAML::dump(response)
    end
  end
  
  def parse_tokens(keys)
    keys.split("&").inject({}) do |hash, pair|
      key, value = pair.split("=")
      hash.merge({ key.to_sym => CGI.unescape(value) })
    end
  end
  
  def get_domain
    URI.parse(@site).host
  end
  
end
