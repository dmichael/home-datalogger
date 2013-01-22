module Setup
	class SimpleDB
    def self.execute
      # log requests using the default rails logger
      # AWS.config(:logger => Rails.logger)
      # load credentials from a file
      config_path = File.expand_path(File.dirname(__FILE__)+"/config/aws.yml")
      AWS.config(YAML.load(File.read(config_path)))

      domain_prefix = 'currentcost-'
      AWS::Record.domain_prefix = domain_prefix

      full_shard_name = domain_prefix + RealTimeMessage.domain_name

      domain = AWS::SimpleDB::Domain.new(full_shard_name)

      unless domain.exists?
        puts "Creating domain #{full_shard_name}"
        RealTimeMessage.create_domain 
      end
    end
  end
end