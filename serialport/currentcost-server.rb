require 'eventmachine'
require File.join File.dirname(__FILE__), 'serialport-proxy'

# '/dev/tty.PL2303-00001014'

# raise "Call with path to the serial port as first arg" unless dev = ARGV.shift
dev = '/dev/ttyUSB0'

# Configure the SerialPortProxy for the CurrentCost CC128
options = {
  host: '0.0.0.0',
  port: 8080,  
  dev:  dev,
  baud: 57600,
  databits: 8,
  stopbits: 1,
  # Let the parity be default
} 


EventMachine.run {
  proxy = SerialPortProxy.new(options)

  cleanup = lambda {
    proxy.stop
    EventMachine.stop 
  }

  Signal.trap("INT")  { cleanup.call }
  Signal.trap("TERM") { cleanup.call }

  
  proxy.start
  puts "CurrentCost proxy started"
}

puts "CurrentCost proxy server stopped."

