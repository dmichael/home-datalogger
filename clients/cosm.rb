require 'eventmachine'
require File.join File.dirname(__FILE__), 'pachube-stream/lib/pachube-stream'

EventMachine.run do
  connection = PachubeStream::Connection.connect(:api_key => ENV["PACHUBE_API_KEY"])

  request = connection.subscribe("/feeds/103394")
  request.on_datastream do |response|
    puts response
  end

end