require 'daemons'

server = File.expand_path(File.dirname(__FILE__)+"/currentcost-proxy-server.rb")

Daemons.run server, '/dev/ttyUSB0'