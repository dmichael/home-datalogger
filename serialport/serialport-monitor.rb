require 'serialport'

# An Observable class that others can user to 
class SerialPortMonitor

  def initialize(dev, baud = 57600, databits = 8, stopbits = 1, parity = SerialPort::NONE)
    @channel ||= EM::Channel.new
    @serial  = SerialPort.new(dev, baud, databits, stopbits, parity)
  end

  def subscribe &block
    @channel.subscribe &block
  end

  def unsubscribe sid
    @channel.unsubscribe sid
  end

  def close
    # @serial.close
  end

  def run
    # TODO: Need to handle broken pipes
    while true do
      while (xml = @serial.gets) do
        @channel.push xml
      end
    end 
  end

end