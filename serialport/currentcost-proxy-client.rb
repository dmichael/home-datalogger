require 'eventmachine'
require 'awesome_print'
require 'cosm'
require 'cosm-rb'
require 'json'

require File.expand_path(File.dirname(__FILE__)+"/../cc128/message")

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
    @cosm = Storage::Cosm.new
  end
  
  def receive_line line
    message = CC128::Message.new line
    hash    = message.to_hash

    # Save the data point to Cosn
    @cosm.save(hash)
  end

  def unbind
    puts "A connection has terminated"
  end

end

#host = '71.183.45.85'
host = '0.0.0.0'

EventMachine.run do
  EventMachine.connect(host, 8080, CurrentCostClient)
end