class RealtimeMessage < ActiveRecord::Base
	attr_accessible :src, :dsb, :time, :tmprF, :sensor, :type, :radio_id, :ch1_watts, :ch2_watts, :ch3_watts
end