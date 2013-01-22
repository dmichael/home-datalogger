# TODO:
# This needs to be grouped by the sensor_num!

task :aggregate => :environment do 

  # This is the price collected from the utility bill including
  # delivery and other per kWh charges
  price_per_kwh = 0.1248 # dollars
  
  # The basic query retreives all messages sent by the CC128 for the current month
  query = RealtimeMessage.this_month

  # Now we loop through each of the messages, calculating the kWh usage during
  # each interval (which is assumed to be constant, producing a step function)
  previous = query.first
  # Here we 'reduce' the rest of the records summing the kWh usage for each measurement
  usage = query[1..query.count].reduce(0) do |sum, message|
    # Get elapsed time
    elapsed_seconds = (message.created_at - previous.created_at)
    elapsed_hours   = elapsed_seconds/3600

    # Sum all the watt reading from each channel
    watts = [message.ch1_watts, message.ch2_watts, message.ch3_watts].reduce(0) {|sum, measure| sum + (measure || 0)}

    # TODO: we need to account for all channel readings
    # kW  = watts/1000.0
    kW  = message.ch1_watts/1000.0 # convert watts to kilowatts
    kWh = elapsed_hours * kW

    previous = message

    sum + kWh
  end

  # The cost calculation then is simple
  cost = usage * price_per_kwh
  # Total measured time for the month of ---
  elapsed = query.last.created_at - query.first.created_at

  p "Usage: #{usage.round(4)} kWh @ $#{price_per_kwh} = $#{cost.round(2)}"
  p "Accounting for #{(elapsed/86400).round(4)} days (#{(elapsed/3600).round(4)} hours) in #{Date::MONTHNAMES[Date.today.month]}"
 
  # This is what the CC128 unit calculates
  # --------------------------------------- 
  # w = last_message.first.ch1_watts
  # cost = ((740*24)*0.1248)/1000
  # cost = ((w*24)*price_per_kwh)/1000
  # ap "Cost per day: $#{cost.round(2)}"  
end