#!/usr/bin/env ruby


=begin
  
  11.5190 - Delivery
  0.4922 - SBC/RPS
  0.4676 - Temp NY State Surcharge
  -------
  12.4788
=end


require 'serialport'
require 'crack'
require 'awesome_print'
require 'time'
require 'aws-sdk'

require File.expand_path(File.dirname(__FILE__)+"/models/message")
require File.expand_path(File.dirname(__FILE__)+"/models/simple_db/real_time_message")

if ARGV.size < 1
  list = `ls /dev/tty.*`
  STDERR.print <<EOF
  Usage: #{$0} serial_port
  Is serial_port one of:
  #{list.split(' ')}
EOF
  exit(1)
end



Setup::SimpleDB.execute
Setup::ActiveRecord.execute


# The CC128 Display Unit outputs ASCII text over its serial port at 
# 57600 baud, 1 start, 8‐bit data, 1 stop, no parity, no handshake.

sp = SerialPort.new(ARGV[0], 57600, 8, 1, SerialPort::NONE)

while true do
  while (xml = sp.gets) do
    begin
      record = Message.parse(xml)
      ap record
      ap record.save 
    rescue Exception => e
      ap e.message
      ap e
    end
  end
end 

sp.close
