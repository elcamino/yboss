require "singleton"

module YBoss
  class Config
    include Singleton
    attr_accessor :oauth_key, :oauth_secret, :proxy
  end

  def self.config
    if block_given?
      yield Config.instance
    end
    Config.instance
  end
end
