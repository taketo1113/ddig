# frozen_string_literal: true

require_relative "ddig/version"
require_relative "ddig/resolver/do53"

module Ddig
  class Error < StandardError; end

  def self.lookup(hostname)
    @hostname = hostname

    @do53 = Ddig::Resolver::Do53.new(hostname: @hostname).lookup

    {
      do53: @do53,
    }
  end
end
