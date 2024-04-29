# frozen_string_literal: true

RSpec.describe Ddig::Ip do
  it "#enable_ipv4?" do
    skip "IPv4 enabled: #{Ddig::Ip.enable_ipv4?}" unless enable_ipv4?
    expect(Ddig::Ip.enable_ipv4?).to be true
  end

  it "#enable_ipv6?" do
    skip "IPv6 enabled: #{Ddig::Ip.enable_ipv6?}" unless enable_ipv6?
    expect(Ddig::Ip.enable_ipv6?).to be true
  end
end
