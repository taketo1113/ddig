# frozen_string_literal: true

require_relative "ddig/version"
require_relative "ddig/nameserver"
require_relative "ddig/ip"
require_relative "ddig/resolver/do53"
require_relative "ddig/resolver/dot"
require_relative "ddig/resolver/doh_h1"
require_relative "ddig/ddr"

module Ddig
  class Error < StandardError; end

  def self.lookup(hostname, nameservers: nil, use_ipv4: nil, use_ipv6: nil)
    @hostname = hostname
    @nameservers = nameservers
    @use_ipv4 = use_ipv4
    @use_ipv6 = use_ipv6

    @nameserver = Ddig::Nameserver.new(nameservers: @nameservers)
    @ip = Ddig::Ip.new(use_ipv4: @use_ipv4, use_ipv6: @use_ipv6)

    @do53_ipv4 = Ddig::Resolver::Do53.new(hostname: @hostname, nameservers: @nameserver.servers, ip: :ipv4).lookup unless @ip.ip_type == :ipv6
    @do53_ipv6 = Ddig::Resolver::Do53.new(hostname: @hostname, nameservers: @nameserver.servers, ip: :ipv6).lookup unless @ip.ip_type == :ipv4

    @ddr = Ddig::Ddr.new(nameservers: @nameservers, ip: @ip.ip_type)

    {
      do53: {
        ipv4: @do53_ipv4,
        ipv6: @do53_ipv6,
      },
      ddr: @ddr.designated_resolvers
    }
  end
end
