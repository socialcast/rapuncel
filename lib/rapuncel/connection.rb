module Rapuncel
  class Connection
    attr_accessor :host, :port, :path, :ssl, :user, :password, :cookie_file_path, :ssl_version
    alias_method :ssl?, :ssl

    def initialize configuration = {}
      load_configuration configuration
    end

    def url
      "#{protocol}://#{host}:#{port}#{path}"
    end

    def host= value
      @host = value.to_s.sub /^http(s)?\:\/\//, ''

      if $1 == 's'
        @ssl = true
      end

      @host
    end

    def path= value
      unless value =~ /^\//
        value = "/" + value
      end

      @path = value
    end

    def headers= headers
      @headers = {
        'User-Agent' => 'Rapuncel, Ruby XMLRPC Client'
      }.merge headers.stringify_keys
    end

    def headers
      @headers.merge 'Accept' => 'text/xml', 'content-type' => 'text/xml'
    end

    def protocol
      ssl? ? 'https' : 'http'
    end
    alias_method :scheme, :protocol

    def auth?
      !!user && !!password
    end

    def ssl_version
      case @ssl_version
      when 'tslv1'
        Curl::CURL_SSLVERSION_TLSv1
      when 'sslv2'
        Curl::CURL_SSLVERSION::SSLv2
      when 'sslv3'
        Curl::CURL_SSLVERSION_SSLv3
      else
        Curl::CURL_SSLVERSION_DEFAULT
      end
    end

    protected
    def load_configuration configuration
      configuration = configuration.symbolize_keys

      self.ssl      = !!configuration[:ssl]
      self.host     = configuration[:host]    || 'localhost'
      self.port     = configuration[:port]    || '8080'
      self.path     = configuration[:path]    || '/'
      self.headers  = configuration[:headers] || {}
      self.user     = configuration[:user]
      self.password = configuration[:password]
      self.cookie_file_path = configuration[:cookie_file_path]
      self.ssl_version = configuration[:ssl_version]
    end
  end
end
