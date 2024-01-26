require 'resolv'

module Ddig
  module Resolver
    # DNS Resolver of UDP/53
    class Do53
      attr_reader :hostname, :nameservers
      attr_reader :a, :aaaa

      def initialize(hostname:, nameservers: nil)
        @hostname = hostname

        set_nameservers(nameservers)
      end

      def lookup
        @a = Resolv::DNS.open(nameserver: @nameservers) do |dns|
          ress = dns.getresources(@hostname, Resolv::DNS::Resource::IN::A)
          ress.map { |resource| resource.address.to_s }
        end

        @aaaa = Resolv::DNS.open(nameserver: @nameservers) do |dns|
          ress = dns.getresources(@hostname, Resolv::DNS::Resource::IN::AAAA)
          ress.map { |resource| resource.address.to_s }
        end

        self
      end

      def set_nameservers(nameservers)
        if nameservers.nil?
          @nameservers = Resolv::DNS::Config.default_config_hash[:nameserver]
        else
          @nameservers = nameservers
        end
      end
    end
  end
end
