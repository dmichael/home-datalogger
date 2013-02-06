require 'eventmachine'
require 'awesome_print'
require File.join File.dirname(__FILE__), '../cc128/message'

module EM
  # Received data is an XML string
  def receive_data(xml)
    message = CC128::Message.new xml
    hash = message.to_hash
    # Not all messages are parsable ... dump those here
    if hash.nil?
      ap xml 
    else
      ap hash
    end
  end

  def unbind
    puts "A connection has terminated"
  end

end
# '71.183.45.85'

EventMachine.run do
  EventMachine.connect('0.0.0.0', 8080, EM)
end