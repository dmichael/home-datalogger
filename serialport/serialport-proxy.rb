# A general EventMachine proxy 

require 'eventmachine'
require 'serialport'
require 'hashie'
require File.join File.dirname(__FILE__), 'serialport-monitor'


class SerialPortProxy

  def initialize(options = {})
    options = Hashie::Mash.new(options)

    @dev = options.dev # We cant guess this one
    raise "Please give the path to the serial connection" unless @dev

    @host = options.host || '0.0.0.0'
    @port = options.port || 8080

    @baud     = options.baud || 57600
    @databits = options.databits || 8
    @stopbits = options.stopbits || 1
    @parity   = options.parity || SerialPort::NONE
  end

  # This call will block (since it starts the reactor loop)
  def start
    @monitor = SerialPortMonitor.new @dev, @baud, @databits, @stopbits, @parity

    # Ye olde reactor loop
    EventMachine.run do
    
      EventMachine.start_server @host, @port, Connection, @monitor
      

      @thread = Thread.new {
        @monitor.run
      }

      puts "SerialPortProxy started at #{@dev} serving to #{@host}:#{@port}"
    end

  end

  
  def stop
    puts "Stopping SerialPortProxy at #{@host}:#{@port} and releasing #{@dev}"
    # cleanup
    @monitor.close
    @thread.kill
  end

  # An simple EventMachine connection class used to proxy observed events from the serial port monitor 
  # to connected clients over TCP. Requires the SerialPortMonitor instance
  module Connection
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

end





