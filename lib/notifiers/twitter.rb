require 'twitter'

module Notifier
  class Twitter
    def initialize
      config_path    = File.expand_path(File.dirname(__FILE__)+"/../../config/twitter.yml")
      @config = YAML.load(File.read(config_path))
      @client = 
      ::Twitter::Client.new({
        consumer_key:       @config["consumer_key"],
        consumer_secret:    @config["consumer_secret"],
        oauth_token:        @config["oauth_token"],
        oauth_token_secret: @config["oauth_token_secret"]
       }) 
      
    end

    def send message
      begin
        @config['recipients'].each do |recipient|
          @client.update "d #{recipient} #{message}"
        end
      rescue ::Twitter::Error => e
        puts "#{e.class} - #{e.message}"
      end
    end
  end
end