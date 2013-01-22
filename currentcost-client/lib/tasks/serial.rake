# /dev/tty.PL2303-00002014

namespace :serial do
  desc "Start monitoring the serial port"
  task :start => :environment do
        # The CC128 Display Unit outputs ASCII text over its serial port at 
    # 57600 baud, 1 start, 8‐bit data, 1 stop, no parity, no handshake.

    sp = SerialPort.new(ARGV[1], 57600, 8, 1, SerialPort::NONE)

    while true do
      while (xml = sp.gets) do
        message = CC128::Message.create(xml)
        message.save
      end
    end 

    sp.close

  end 
end
