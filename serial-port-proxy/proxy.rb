# A quick and dirty proxy from the CurrentCost to an insecure Websocket connection
# This proxy is currently running on a Raspberry Pi and allows me to develop code 
# to manage the data stream on a local machine.

require 'eventmachine'
require 'em-websocket'
require 'serialport'

# '/dev/tty.PL2303-00001014'

raise "Call with path to the serial port as first arg" unless dev = ARGV.shift

host = '0.0.0.0'
port = 8080

# An Observable class that others can user to 
class SerialPortMonitor

  def initialize(dev, baud = 57600, databits = 8, stopbits = 1, parity = SerialPort::NONE)
    @channel ||= EM::Channel.new
    #@serial  = SerialPort.new(dev, baud, databits, stopbits, parity)
  end

  def subscribe &block
    @channel.subscribe &block
  end

  def unsubscribe sid
    @channel.unsubscribe sid
  end

  def close
    @serial.close
  end

  def run
    # TODO: Need to handle broken pipes
    while true do
      #while (xml = @serial.gets) do
        @channel.push "xml"
        sleep 1
      #end
    end 
  end

end

# An EventMachine connection class used to proxy observed events from the serial port monitor 
# to connected clients over TCP
module SerialPortProxy
  # monitor: SerialPortMonitor
  def initialize(monitor)
    @monitor = monitor
  end

  def post_init
    puts "Received a new connection"
    @sid =  @monitor.subscribe { |msg| 
      send_data msg 
    }
    # also tell the client that we are connected and with our subscription id
    send_data "#{@sid} connected"
  end

  def unbind
    puts "Connection closed for subscriber #{@sid}"
    @monitor.unsubscribe(@sid)  
  end

end



# Ye olde reactor loop
EventMachine.run do
  monitor = SerialPortMonitor.new dev, 57600, 8, 1, SerialPort::NONE

  EventMachine.start_server host, port, SerialPortProxy, monitor

  Thread.new {
    monitor.run
    # @serial.close
  }

  puts "SerialPortProxy started at #{host}:#{port}"
end

# Cleanup - just in case the loop termination didnt get it 
# @serial.close
