module SimpleDB
  class RealtimeMessage < AWS::Record::Base
    set_shard_name 'real-time-message'

    string_attr :src
    integer_attr :dsb
    datetime_attr :time
    string_attr :tmpr
    
    string_attr :tmprF
    string_attr :tmprC

    integer_attr :sensor
    integer_attr :radio_id
    integer_attr :type

    string_attr :ch1_watts
    string_attr :ch2_watts
    string_attr :ch3_watts

    timestamps



    def self.parse message
    	
      # Time
      message["time"] = Time.parse(message["time"])
      message["radio_id"] = message.delete "id"
      # Format the channel watts
      if ch1 = message.delete("ch1")
        message["ch1_watts"] = ch1["watts"] 
      end
      if ch2 = message.delete("ch2")
        message["ch2_watts"] = ch2["watts"] 
      end
      if ch3 = message.delete("ch3")
        message["ch3_watts"] = ch3["watts"] 
      end


      record = self.new(message)
    end


  end
end