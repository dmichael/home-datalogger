require 'crack'
require 'hashie'

# NB: The /r/n at the end of lines are part of the 'line' protocol 
# and are NOT garbage. You should split these messages before creating
# a Message instance

module CC128
  class Message
    attr_accessor :xml, :type

    def initialize xml
      @type = :realtime
      @xml  = xml # sanitize xml
      hash  = parse @xml

      # Catch parse errors ...
      unless message = hash["msg"]
        @type = :history
        return
      end
    
      @hash = if message["hist"]
        puts "We are not formatting history messages"
        message
      else
        format_realtime(message)
      end
    end

    def to_json
      JSON.generate(@hash)
    end

    def to_hash
      Hashie::Mash.new(@hash)
    end

    # Strip out crap from the XML string
    # def sanitize xml
    #   xml.gsub('\n','').gsub('\r','')
    # end

    # Turn the XML string into a Hash
    def parse xml
      begin
        output = Crack::XML.parse xml
      rescue Exception => e
        puts "Exception parsing message #{e.message}"
        return {}
      end
    end

    # Flatten parsed message, converting type
    def format_realtime message
      message["dsb"]   = message["dsb"].to_i
      
      message["tmpr"]  = message["tmpr"].to_f if message["tmpr"]
      message["tmprC"] = message["tmprC"].to_f if message["tmprC"]
      message["tmprF"] = message["tmprF"].to_f if message["tmprF"]
  
      message["sensor_num"]  = message.delete("sensor").to_i
      message["sensor_type"] = message.delete("type").to_i

      message["time"]     = Time.parse(message["time"])
      message["radio_id"] = message.delete("id").to_i

      # Format the channel watts
      if ch1 = message.delete("ch1")
        message["ch1_watts"] = ch1["watts"].to_i 
      end
      if ch2 = message.delete("ch2")
        message["ch2_watts"] = ch2["watts"].to_i
      end
      if ch3 = message.delete("ch3")
        message["ch3_watts"] = ch3["watts"].to_i 
      end
      
      message
    end

  end
end