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

        @nameserver = Ddig::Nameserver.new(nameservers: nameservers)
        set_nameservers
      end

      def lookup
        if @nameservers.empty?
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

      def set_nameservers
        @nameservers = @nameserver.servers

        if @ip == :ipv4
          @nameservers = @nameserver.servers_ipv4
        end

        if @ip == :ipv6
          @nameservers = @nameserver.servers_ipv6
        end
      end
    end
  end
end
