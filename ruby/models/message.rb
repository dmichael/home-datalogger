module Message
	def self.parse xml
    output = Crack::XML.parse xml
    message = output["msg"]

    if message["hist"]
      p "Parse history output"
    else
      SimpleDB::RealtimeMessage.parse message
    end
	end
end