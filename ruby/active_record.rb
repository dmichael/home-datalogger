require 'active_record'

module Setup
  class ActiveRecord
    def self.execute
      ActiveRecord::Base.establish_connection(
      	:adapter => "mysql2",  
      	:host => "hobbying.ciqfyhrt5eh2.us-east-1.rds.amazonaws.com",
        :port => 3306,
       	:database => "currentcost", 
       	:username => "root", 
       	:password => "password"  
      )


      ActiveRecord::Migration.create_table :realtime_messages, :options => 'ENGINE=InnoDB DEFAULT CHARSET=utf8' do |t|
        t.string :src
        t.integer :dsb
        t.datetime :time

        t.float :tmpr
        
        t.float :tmprF
        t.float :tmprC

        t.integer :sensor
        t.integer :radio_id
        t.integer :type

        t.integer :ch1_watts
        t.integer :ch2_watts
        t.integer :ch3_watts

        t.timestamps
      end unless ActiveRecord::Base.connection.table_exists? :realtime_messages
    end
  end
end