require 'eventmachine'
require 'awesome_print'
require 'cosm'
require 'cosm-rb'
require 'json'
require 'twitter'
require 'logger'

here = File.expand_path(File.dirname(__FILE__))

require here+"/../cc128/message"
require here+"/../lib/notifiers/twitter"



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
  
  def logger 
    @logger ||= Logger.new(File.expand_path(File.dirname(__FILE__))+'/log.txt')
  end

  def post_init
    @services = []
    @services.push Storage::Cosm.new

    @notifiers = []
    @notifiers.push Notifier::Twitter.new    
  end

  def connection_completed
    message = "connection-initialized|#{Host}:#{Port}|#{Time.now.to_i}"
    logger.info "A connection has initialized"
    @notifiers.each {|notifier| notifier.send(message) }
  end
  
  def receive_line line
    message = CC128::Message.new line
    hash    = message.to_hash
    puts hash
    return if hash.nil? or hash.empty?

    # Save the data point to Cosm
    @services.each {|service| service.save(hash) }
  end

  def unbind
    message = "connection-terminated|#{Host}:#{Port}|#{Time.now.to_i}" 
    @notifiers.each {|notifier| notifier.send(message) }
    logger.info "A connection has terminated - trying to reconnect"
    reconnect(Host, Port)
  end
end


EventMachine.run do
  server = EventMachine.connect(Host, Port, CurrentCostClient)
  
  EventMachine.error_handler do |e|
    server.logger.error "Error raised during event loop: #{e.message}"
    server.logger.error(e.backtrace.join "\n")
  end
end