module CC128
  class RealtimeMessage < ActiveRecord::Base
    attr_accessible :src, :dsb, :time, :tmprF, :sensor_num, :sensor_type, :radio_id, :ch1_watts, :ch2_watts, :ch3_watts, :mac_address

    before_save do |record|
      record.mac_address = Mac.address
    end


    def self.this_month 
      now = Time.now
      first_of_month = Date.civil(now.year, now.month, 1)
      last_of_month  = Date.civil(now.year, now.month, -1)

      self.where {
        (created_at >= first_of_month) & (created_at <= last_of_month)
      }
      .where { # Filter out bad records (which happens)
        (ch1_watts.not_eq nil) | (ch2_watts.not_eq nil) | (ch3_watts.not_eq nil)
      }
    end
  end
end