require 'daemons'

server = File.expand_path(File.dirname(__FILE__)+"/currentcost-client.rb")

Daemons.run server