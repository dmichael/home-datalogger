module CC128
  class Message

    def self.create xml
      xml  = sanitize xml
      hash = parse xml

      # There could be a parse error or something 
      return nil unless message = hash["msg"]
    
      if message["hist"]
        # We are not handling history messages
      else
        hash = format_realtime(message)
        # Return an ActiveRecord
        return RealtimeMessage.new hash
      end
    end

    def self.sanitize xml
      xml.gsub('\n','').gsub('\r','')
    end

    def self.parse xml
      begin
        output = Crack::XML.parse xml
      rescue Exception => e
        Rails.logger.error "Exception parsing message #{e.message}"
        return {}
      end
    end

    def self.format_realtime message
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