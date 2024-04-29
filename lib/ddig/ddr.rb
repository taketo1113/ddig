require 'resolv'

require_relative "ddr/verify_cert"
require_relative "ddr/designated_resolver"

module Ddig
  # DDR client (Discovery of Designated Resolvers)
  class Ddr
    attr_reader :nameservers, :ip
    attr_reader :svcb_records, :designated_resolvers

    def initialize(nameservers: nil, ip: nil)
      @ip = ip

      @nameserver = Ddig::Nameserver.new(nameservers: nameservers)
      set_nameservers

      # discover designated resolvers
      query_svcb_records
      discover_designated_resolvers
      verify_discovery
    end

    def query_svcb_records
      @svcb_records = []

      if @nameservers.empty?
        return @svcb_records
      end

      @nameservers.each do |nameserver|
        svcb_rrset = Resolv::DNS.open(nameserver: nameserver) do |dns|
          dns.getresources('_dns.resolver.arpa', Resolv::DNS::Resource::IN::SVCB)
        end

        svcb_rrset.sort_by!(&:priority)

        @svcb_records += svcb_rrset.map { |svcb_record| { unencrypted_resolver: nameserver, svcb_record: svcb_record } }
      end

      @svcb_records
    end

    # Discovery Designated Resolvers from SVCB RR Set
    # ref. https://www.rfc-editor.org/rfc/rfc9461.html
    def discover_designated_resolvers
      @designated_resolvers = []

      @svcb_records.each do |item|
        unencrypted_resolver = item[:unencrypted_resolver]
        svcb_record = item[:svcb_record]

        target = svcb_record.target.to_s
        priority = svcb_record.priority
        protocols = svcb_record.params[:alpn].protocol_ids
        port = svcb_record.params[:port]&.port
        dohpath = svcb_record.params[:dohpath]&.template
        ipv4hint = svcb_record.params[:ipv4hint]&.addresses
        ipv6hint = svcb_record.params[:ipv6hint]&.addresses

        # Skip AliasMode of SVCB RR
        if priority.zero?
          next
        end

        protocols.each do |protocol|
          do53_v4 = ::Ddig::Resolver::Do53.new(hostname: target, nameservers: [unencrypted_resolver], ip: :ipv4).lookup
          do53_v6 = ::Ddig::Resolver::Do53.new(hostname: target, nameservers: [unencrypted_resolver], ip: :ipv6).lookup

          # ipv4
          unless @ip == :ipv6
            unless do53_v4.nil? || do53_v4.a.nil?
              do53_v4.a.each do |address|
                designated_resolver = ::Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: unencrypted_resolver, target: target, protocol: protocol, port: port, dohpath: dohpath, address: address.to_s, ip: :ipv4)
                @designated_resolvers << designated_resolver
              end
            end
            unless do53_v6.nil? || do53_v6.a.nil?
              do53_v6.a.each do |address|
                designated_resolver = ::Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: unencrypted_resolver, target: target, protocol: protocol, port: port, dohpath: dohpath, address: address.to_s, ip: :ipv4)
                @designated_resolvers << designated_resolver
              end
            end
          end

          # ipv6
          unless @ip == :ipv4
            unless do53_v4.nil? || do53_v4.aaaa.nil?
              do53_v4.aaaa.each do |address|
                designated_resolver = ::Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: unencrypted_resolver, target: target, protocol: protocol, port: port, dohpath: dohpath, address: address.to_s, ip: :ipv6)
                @designated_resolvers << designated_resolver
              end
            end
            unless do53_v6.nil? || do53_v6.aaaa.nil?
              do53_v6.aaaa.each do |address|
                designated_resolver = ::Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: unencrypted_resolver, target: target, protocol: protocol, port: port, dohpath: dohpath, address: address.to_s, ip: :ipv6)
                @designated_resolvers << designated_resolver
              end
            end
          end

          # ipv4hint
          unless ipv4hint.nil? || @ip == :ipv6
            ipv4hint.each do |address|
              ip = :ipv4
              designated_resolver = ::Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: unencrypted_resolver, target: target, protocol: protocol, port: port, dohpath: dohpath, address: address.to_s, ip: ip)
              @designated_resolvers << designated_resolver
            end
          end

          # ipv6hint
          unless ipv6hint.nil? || @ip == :ipv4
            ipv6hint.each do |address|
              ip = :ipv6
              designated_resolver = ::Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: unencrypted_resolver, target: target, protocol: protocol, port: port, dohpath: dohpath, address: address.to_s, ip: ip)
              @designated_resolvers << designated_resolver
            end
          end
        end
      end

      @designated_resolvers.uniq! { |designated_resolver| designated_resolver.uniq_key }
    end

    def verify_discovery
      @designated_resolvers.map! do |designated_resolver|
        designated_resolver.verify
        designated_resolver
      end
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
