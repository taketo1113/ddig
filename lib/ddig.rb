# frozen_string_literal: true

require_relative "ddig/version"
require_relative "ddig/resolver/do53"
require_relative "ddig/resolver/dot"
require_relative "ddig/ddr"

module Ddig
  class Error < StandardError; end

  def self.lookup(hostname)
    @hostname = hostname

    @do53_ipv4 = Ddig::Resolver::Do53.new(hostname: @hostname, ip: :ipv4).lookup
    @do53_ipv6 = Ddig::Resolver::Do53.new(hostname: @hostname, ip: :ipv6).lookup

    @ddr = Ddig::Ddr.new

    {
      do53: {
        ipv4: @do53_ipv4,
        ipv6: @do53_ipv6,
      },
      ddr: @ddr.designated_resolvers
    }
  end
end
