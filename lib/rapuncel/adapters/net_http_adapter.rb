require 'net/http'
require 'net/https'
require 'cookiejar'
require 'json'

module Rapuncel
  module Adapters
    module NetHttpAdapter
      # Small response wrapper
      class HttpResponse
        def initialize response
          @response = response
        end

        def success?
          @response.is_a? Net::HTTPOK
        end

        def body
          @response.body
        end

        def code
          @response.code
        end
      end

      # Dispatch a XMLRPC via HTTP and return a response object.
      def send_method_call str
        cookie_jar = if File.exists?(connection.cookie_file_path)
          File.open(connection.cookie_file_path, 'r') do |file|
            contents = file.read
            if contents.empty? 
              CookieJar::Jar.new 
            else
              CookieJar::Jar.json_create(JSON.parse(contents))
            end
          end
        else
          CookieJar::Jar.new
        end
        cookie_header = {}
        cookie_header['Cookie'] = cookie_jar.get_cookie_header("#{connection.ssl? ? 'https' : 'http'}://#{connection.host}/")
        
        request = Net::HTTP::Post.new(connection.path, connection.headers.merge(cookie_header))
        request.basic_auth connection.user, connection.password if connection.auth?
        request.body= str
        
        http = Net::HTTP.new(connection.host, connection.port)
        http.use_ssl = connection.ssl?
        http.set_debug_output(STDOUT)
        response = http.request(request)
        cookie_jar.set_cookie("#{connection.ssl? ? 'https' : 'http'}://#{connection.host}/", response.header['Set-Cookie'])
        
        File.open(connection.cookie_file_path, 'w'){ |file| file.write(cookie_jar.to_json) }
        HttpResponse.new response
      end
    end
  end
end