require 'resolv'

module Ddig
  class Nameserver
    attr_reader :servers

    def initialize(nameservers: nil)
      @nameservers = nameservers

      if @nameservers.nil?
        @servers = default_servers
      elsif @nameservers.is_a?(Array)
        @servers = @nameservers
      else
        @servers = [@nameservers]
      end

      validation_servers
    end

    def servers
      if @servers.count.zero?
        raise Ddig::Error.new('nameservers required')
      end

      @servers
    end

    def default_servers
      Resolv::DNS::Config.default_config_hash[:nameserver]
    end

    def validation_servers
      @servers.uniq.each do |server|
        addr = IPAddr.new(server) rescue nil
        if addr.nil?
          puts "Warning: nameservers has invalid ip address (nameserver: #{server})"
          @servers.delete(server)
        end
      end

      if @servers.count.zero?
        return false
      end

      return true
    end
  end
end
