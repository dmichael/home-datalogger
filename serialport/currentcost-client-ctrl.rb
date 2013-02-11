require 'daemons'

server = File.expand_path(File.dirname(__FILE__)+"/currentcost-proxy-client.rb")

Daemons.run server