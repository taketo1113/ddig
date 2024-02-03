require 'resolv'

module Ddig
  # DDR client (Discovery of Designated Resolvers)
  class Ddr
    attr_reader :nameservers, :ip
    attr_reader :svcb_rrsets, :ddr_nameservers

    def initialize(nameservers: nil, ip: nil)
      @ip = ip

      set_nameservers(nameservers)
    end

    def svcb_rrsets
      if @nameservers.nil? || @nameservers.empty?
        return nil
      end

      @svcb_rrsets = []

      @nameservers.each do |nameserver|
        svcb_rr = Resolv::DNS.open(nameserver: nameserver) do |dns|
          dns.getresources('_dns.resolver.arpa', Resolv::DNS::Resource::IN::SVCB)
        end

        svcb_rr.sort_by!(&:priority)

        @svcb_rrsets += svcb_rr
      end

      @svcb_rrsets
    end

    # DDR Nameservers from SVCB RR Set
    # ref. https://www.rfc-editor.org/rfc/rfc9461.html
    def ddr_nameservers
      @ddr_nameservers = []

      svcb_rrsets.each do |svcb_rrset|
        target = svcb_rrset.target.to_s
        priority = svcb_rrset.priority
        protocols = svcb_rrset.params[:alpn].protocol_ids
        port = svcb_rrset.params[:port]&.port
        dohpath = svcb_rrset.params[:dohpath]&.template
        ipv4hint = svcb_rrset.params[:ipv4hint]&.addresses
        ipv6hint = svcb_rrset.params[:ipv6hint]&.addresses

        # Skip AliasMode of SVCB RR
        if priority.zero?
          next
        end

        protocols.each do |protocol|
          # ipv4
          do53_v4 = ::Ddig::Resolver::Do53.new(hostname: target, nameservers: @nameserver, ip: :ipv4).lookup
          unless do53_v4.nil? || do53_v4.a.nil?
            do53_v4.a.each do |address|
              ddr_nameserver = ::Ddig::Ddr::Nameserver.new(target: target, protocol: protocol, port: port, dohpath: dohpath, address: address.to_s, ip: :ipv4)
              @ddr_nameservers << ddr_nameserver
            end
          end

          # ipv6
          do53_v6 = ::Ddig::Resolver::Do53.new(hostname: target, nameservers: @nameserver, ip: :ipv6).lookup
          unless do53_v6.nil? || do53_v6.aaaa.nil?
            do53_v6.aaaa.each do |address|
              ddr_nameserver = ::Ddig::Ddr::Nameserver.new(target: target, protocol: protocol, port: port, dohpath: dohpath, address: address.to_s, ip: :ipv6)
              @ddr_nameservers << ddr_nameserver
            end
          end

          # ipv4hint
          unless ipv4hint.nil?
            ipv4hint.each do |address|
              ip = :ipv4
              ddr_nameserver = ::Ddig::Ddr::Nameserver.new(target: target, protocol: protocol, port: port, dohpath: dohpath, address: address.to_s, ip: ip)
              @ddr_nameservers << ddr_nameserver
            end
          end

          # ipv6hint
          unless ipv6hint.nil?
            ipv6hint.each do |address|
              ip = :ipv6
              ddr_nameserver = ::Ddig::Ddr::Nameserver.new(target: target, protocol: protocol, port: port, dohpath: dohpath, address: address.to_s, ip: ip)
              @ddr_nameservers << ddr_nameserver
            end
          end
        end
      end

      @ddr_nameservers.uniq! { |nameserver| nameserver.uniq_key }
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
