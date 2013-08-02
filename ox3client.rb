require 'oauth'
require 'yaml'

class OX3APIClient < OAuth::Consumer
  
  OPEN_TIMEOUT =  5 * 60
  READ_TIMEOUT = 15 * 60
  
  def initialize(email, password, site_url, consumer_key, consumer_secret, realm, 
    sso_domain='sso.openx.com', callback='oob', scheme='https', debug=false)
    
    @callback, @site, @debug = callback, site_url, debug
    
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
  def get(path)
    
=begin
    uri = URI.parse(@site)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true if (443==uri.port)
    request = Net::HTTP::Get.new("/ox/3.0/a/account/accountTypeOptions")
    request.add_field('Content-Type', 'application/x-www-form-urlencoded')
    request['Cookie'] = 'openx3_access_token=' + @acccess_token.token + '; domain=' + get_domain + '; path=/'
    response = http.request(request)    
    puts response.body
=end
    http = self.create_http(@site)
    http.open_timeout = OPEN_TIMEOUT
    http.read_timeout = READ_TIMEOUT
    request = self.create_http_request(
      :get, 
      "/ox/3.0" + path, 
      {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Cookie' => 'openx3_access_token=' + @acccess_token.token + '; domain=' + get_domain + '; path=/'
      }
    )
    response = http.request(request)
    response.body
  end
  
  def post(path, body = {})
    http = self.create_http(@site)
    http.open_timeout = OPEN_TIMEOUT
    http.read_timeout = READ_TIMEOUT
    request = self.create_http_request(
      :post, 
      "/ox/3.0" + path,
      body,
      {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Cookie' => 'openx3_access_token=' + @acccess_token.token + '; domain=' + get_domain + '; path=/'
      }
    )
    response = http.request(request)
    response.body
  end
  
  def delete(path)
    http = self.create_http(@site)
    http.open_timeout = OPEN_TIMEOUT
    http.read_timeout = READ_TIMEOUT
    request = self.create_http_request(
      :delete, 
      "/ox/3.0" + path, 
      {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Cookie' => 'openx3_access_token=' + @acccess_token.token + '; domain=' + get_domain + '; path=/'
      }
    )
    response = http.request(request)
    response.body
  end
  
  def logoff
    http = self.create_http(@site)
    http.open_timeout = OPEN_TIMEOUT
    http.read_timeout = READ_TIMEOUT
    request = self.create_http_request(
      :delete, 
      "/ox/3.0/a/session", 
      {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Cookie' => 'openx3_access_token=' + @acccess_token.token + '; domain=' + get_domain + '; path=/'
      }
    )
    response = http.request(request)
    response.body
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
    
    response = self.request(:put, @site + '/ox/3.0/a/session/validate', nil, {}, nil,
      {
        'Content-Type' => 'application/x-www-form-urlencoded',
        'Cookie' => 'openx3_access_token=' + @acccess_token.token + '; domain=' + get_domain + '; path=/'
      }
    )
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