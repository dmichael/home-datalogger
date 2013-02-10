require 'eventmachine'
require 'awesome_print'
require 'cosm'
require 'cosm-rb'
require 'json'
require 'twitter'

require File.expand_path(File.dirname(__FILE__)+"/../cc128/message")
require File.expand_path(File.dirname(__FILE__)+"/../lib/notifiers/twitter")



#host = '71.183.45.85'
# host = '0.0.0.0'
Host = '192.168.1.9'
Port = 8080

# The CC128 sends messages formatted as a line protocol using \n and \r as message delimiters/
# This is actually quite convenient for a client since we do not have to deal with buffers and whatnot 
# on our own. 
#
#
module Storage 
  class Cosm
    attr_reader :feed_id, :api_key

    def initialize
      config_path = File.expand_path(File.dirname(__FILE__)+"/../config/cosm.yml")
      config = YAML.load(File.read(config_path))
      @feed_id = config['feed_id']
      @api_key = config['api_key']
    end

    def save(message)
      watts      = message.ch1_watts
      sensor_num = message.sensor_num
      # Just for documentation
      datastream_id = sensor_num

      datapoint  = ::Cosm::Datapoint.new at: Time.now, value: watts
      uri        = "/v2/feeds/#{@feed_id}/datastreams/#{datastream_id}/datapoints"

      puts "POST #{uri} #{datapoint.to_json}"

      ::Cosm::Client.post(uri, 
        headers: {"X-ApiKey" => @api_key}, 
        body:    JSON.generate(datapoints: [datapoint])
      )
    end

  end
end







module CurrentCostClient
  include EM::Protocols::LineText2

  def post_init


    @services = []
    @services.push Storage::Cosm.new

    @notifiers = []
    @notifiers.push Notifier::Twitter.new

    message = "connection-initialized|#{Host}:#{Port}|#{Time.now.to_i}"
    puts "A connection has initialized"
    @notifiers.each {|notifier| notifier.send(message) }
  end
  
  def receive_line line
    message = CC128::Message.new line
    hash    = message.to_hash

    # Save the data point to Cosn
    @services.each {|service| service.save(hash) }
  end

  def unbind
    message = "connection-terminated|#{Host}:#{Port}|#{Time.now.to_i}" 
    @notifiers.each {|notifier| notifier.send(message) }
    puts "A connection has terminated"
  end

end


EventMachine.run do
  EventMachine.connect(Host, Port, CurrentCostClient)
end