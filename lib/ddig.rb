# frozen_string_literal: true

require_relative "ddig/version"
require_relative "ddig/nameserver"
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

    @do53_ipv4 = Ddig::Resolver::Do53.new(hostname: @hostname, nameservers: @nameserver.servers, ip: :ipv4).lookup
    @do53_ipv6 = Ddig::Resolver::Do53.new(hostname: @hostname, nameservers: @nameserver.servers, ip: :ipv6).lookup

    @ddr = Ddig::Ddr.new(nameservers: @nameservers)

    {
      do53: {
        ipv4: @do53_ipv4,
        ipv6: @do53_ipv6,
      },
      ddr: @ddr.designated_resolvers
    }
  end
end
