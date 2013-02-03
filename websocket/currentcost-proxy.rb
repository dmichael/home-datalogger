# A quick and dirty proxy from the CurrentCost to an insecure Websocket connection
# This proxy is currently running on a Raspberry Pi and allows me to develop code 
# to manage the data stream on a local machine.

require 'eventmachine'
require 'em-websocket'
require 'serialport'

# '/dev/tty.PL2303-00001014'

raise "Call with path to the serial port as first arg" unless usb = ARGV.shift


# It's not clear to me exactly what needs to be in the EM run block

# The EM::Channel is essentially a promise or a future
# it is used by the thread polling the serial port to push updates to the websocket
@channel = EM::Channel.new

@serial  = SerialPort.new(usb, 57600, 8, 1, SerialPort::NONE)

# EM run loop will ensure this thread does not terminate
thread = Thread.new {
  # TODO: Need to handle broken pipes
  while true do
    while (xml = @serial.gets) do
      puts xml
      @channel.push xml
    end
  end 

  @serial.close
}

# Ye olde reactor loop
EventMachine.run do

  EventMachine::WebSocket.start(:host => "0.0.0.0", :port => 8080, :debug => true) do |ws|
    # on socket open, do this ...
    ws.onopen do
      # subscribe to the channel that the serialport is pushing to
      sid = @channel.subscribe { |msg| 
        puts msg
        ws.send msg 
      }

      # also tell the client that we are connected and with our subscription id
      @channel.push "#{sid} connected!"

      # Message from the websocket server - send to client
      ws.onmessage { |msg|
        puts "<#{sid}>: #{msg}"
        @channel.push "<#{sid}>: #{msg}"
      }

      ws.onclose {
        @channel.unsubscribe(sid)
      }
    end
  end 

  puts "Server started"
end

# Cleanup - just in case the loop termination didnt get it 
@serial.close
