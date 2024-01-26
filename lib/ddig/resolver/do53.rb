require 'resolv'

module Ddig
  module Resolver
    # DNS Resolver of UDP/53
    class Do53
      attr_reader :hostname, :nameservers, :ip
      attr_reader :a, :aaaa

      def initialize(hostname:, nameservers: nil, ip: nil)
        @hostname = hostname
        @ip = ip

        set_nameservers(nameservers)
      end

      def lookup
        if @nameservers.nil? || @nameservers.empty?
          return nil
        end

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

        if @ip == :ipv4
          @nameservers = nameservers_ipv4
        end

        if @ip == :ipv6
          @nameservers = nameservers_ipv6
        end
      end

      def nameservers_ipv4
        @nameservers.map do |nameserver|
          if IPAddr.new(nameserver).ipv4?
            nameserver
          end
        end.compact
      end

      def nameservers_ipv6
        @nameservers.map do |nameserver|
          if IPAddr.new(nameserver).ipv6?
            nameserver
          end
        end.compact
      end
    end
  end
end
