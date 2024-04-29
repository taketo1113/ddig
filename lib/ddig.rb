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

  def self.lookup(hostname, nameservers: nil)
    @hostname = hostname
    @nameservers = nameservers

    @nameserver = Ddig::Nameserver.new(nameservers: @nameservers)
    @ip = Ddig::Ip.new

    @do53_ipv4 = Ddig::Resolver::Do53.new(hostname: @hostname, nameservers: @nameserver.servers, ip: :ipv4).lookup if Ddig::Ip.enable_ipv4?
    @do53_ipv6 = Ddig::Resolver::Do53.new(hostname: @hostname, nameservers: @nameserver.servers, ip: :ipv6).lookup if Ddig::Ip.enable_ipv6?

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
