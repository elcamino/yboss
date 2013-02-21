module YBoss
  module Base
    require 'yboss/oauth'
    require 'yboss/config'
    require 'rest-client'
    require 'json'
    require 'uri'

    def fetch(options = {})
      @options.merge!(options)

      url = base_uri + '?'
      url += @options.find_all { |k,v| ! v.nil? }.map { |k,v| "#{k}=#{URI.escape(v)}" }.join('&')

      if ! @oauth
        @oauth = YBoss::Oauth.new
        @oauth.consumer_key = YBoss::Config.instance.oauth_key
        @oauth.consumer_secret = YBoss::Config.instance.oauth_secret
      end

      parsed_url = URI.parse(url)
      url += "?" + @oauth.sign(parsed_url).query_string

      data = nil

      Net::HTTP.start( parsed_url.host ) { | http |
        req = Net::HTTP::Get.new "#{ parsed_url.path }?" + @oauth.sign(parsed_url).query_string
        response = http.request(req)
        if ! response.is_a?(Net::HTTPSuccess)
          raise FetchError.new("Got error while fetching #{url}: #{response.code} #{response.message}")
        end
        data = JSON.parse(response.read_body)
      }

      data
    end

    def method_name
      # derive the method name from the class name
      #
      self.class.to_s.downcase.sub(/^.+?::/, '').gsub(/::/, '.')
    end

    def base_uri
      ::YBoss::SERVICE_PREFIX + method_name
    end
  end

  class FetchError < Exception ; end
end
