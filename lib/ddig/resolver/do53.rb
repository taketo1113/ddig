require 'resolv'
require 'json'

module Ddig
  module Resolver
    # DNS Resolver of UDP/53
    class Do53
      attr_reader :hostname, :nameservers, :ip
      attr_reader :a, :aaaa, :https

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

        @https = Resolv::DNS.open(nameserver: @nameservers) do |dns|
          ress = dns.getresources(@hostname, Resolv::DNS::Resource::IN::HTTPS)
          ress.map { |resource| { priority: resource.priority, target: resource.target != Resolv::DNS::Name.create(".") ? resource.target.to_s : '.' , alpn: resource.params[:alpn].protocol_ids } }
        end

        self
      end

      def as_json(*)
        {
          a: @a,
          aaaa: @aaaa,
          https: @https,
          hostname: @hostname,
          nameservers: @nameservers,
          ip: @ip,
        }
      end

      def to_json(*args)
        as_json.to_json
      end

      def to_cli
        @a.each do |address|
          rr_type = 'A'
          puts "#{@hostname}\t#{rr_type}\t#{address}"
        end
        @aaaa.each do |address|
          rr_type = 'AAAA'
          puts "#{@hostname}\t#{rr_type}\t#{address}"
        end

        puts
        puts "# SERVER: #{@nameservers.join(', ')}"
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
