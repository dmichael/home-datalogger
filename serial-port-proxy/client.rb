require 'eventmachine'
module EM

  def receive_data(data)
    puts "RECEIVED #{data}"
  end

  def unbind
    puts "A connection has terminated"
  end

end

EventMachine.run do
  EventMachine.connect('0.0.0.0', 8080, EM)
end