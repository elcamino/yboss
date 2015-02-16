module YBoss
  class Base
    require 'yboss/oauth'
    require 'yboss/config'
    require 'yboss/result/base'
    require 'net/http'
    require 'json'
    require 'uri'

    attr_reader :credits, :options

    def initialize(options = {})
      if options.is_a?(Hash)
        options.delete('format')
      end

      @options = {
        'format' => 'json',
      }.merge(options)

      @oauth = YBoss::Oauth.new
      @oauth.consumer_key = YBoss::Config.instance.oauth_key
      @oauth.consumer_secret = YBoss::Config.instance.oauth_secret
    end

    def call(options = {})
      data = fetch(@options.merge(options))

      clazz = YBoss.class_from_string(self.class.to_s + '::Result')
      clazz.new(data)
    end


    def fetch(options = {})
      @options.merge!(options)

      url = base_uri + '?'
      url += @options.find_all { |k,v| ! v.nil? }.map { |k,v| "#{k}=#{CGI.escape(v)}" }.join('&')

      parsed_url = URI.parse(url)
      url += "?" + @oauth.sign(parsed_url).query_string

      data = nil

      if YBoss::Config.instance.proxy
        proxy_uri = URI.parse(YBoss::Config.instance.proxy)

        Net::HTTP::Proxy(proxy_uri.host, proxy_uri.port).start(parsed_url.host)  { | http |
          req = Net::HTTP::Get.new "#{ parsed_url.path }?" + @oauth.sign(parsed_url).query_string
          response = http.request(req)
          if ! response.is_a?(Net::HTTPSuccess)
            raise FetchError.new("Got error while fetching #{url}: #{response.code} #{response.message}")
          end

          data = JSON.parse(response.read_body)
        }
      else
        Net::HTTP.start( parsed_url.host ) { | http |
          req = Net::HTTP::Get.new "#{ parsed_url.path }?" + @oauth.sign(parsed_url).query_string
          response = http.request(req)
          if ! response.is_a?(Net::HTTPSuccess)
            raise FetchError.new("Got error while fetching #{url}: #{response.code} #{response.message}")
          end

          data = JSON.parse(response.read_body)
        }
      end


      data
    end

    def method_name
      # derive the method name from the class name
      #
      self.class.to_s.downcase.split(/::/).last
    end

    def base_uri
      ::YBoss::SERVICE_PREFIX + method_name
    end
  end

  class FetchError < Exception ; end
end
