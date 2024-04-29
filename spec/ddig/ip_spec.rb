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

  context "ip_type" do
    it "return :all with use_ipv4 & use_ipv6 is true" do
      use_ipv4 = true
      use_ipv6 = true

      expect(Ddig::Ip.new(use_ipv4: use_ipv4, use_ipv6: use_ipv6).ip_type).to be :all
    end

    it "return :ipv4 with use_ipv4: true & use_ipv6: false" do
      use_ipv4 = true
      use_ipv6 = false

      expect(Ddig::Ip.new(use_ipv4: use_ipv4, use_ipv6: use_ipv6).ip_type).to be :ipv4
    end

    it "return :all with use_ipv4: false & use_ipv6: true" do
      use_ipv4 = false
      use_ipv6 = true

      expect(Ddig::Ip.new(use_ipv4: use_ipv4, use_ipv6: use_ipv6).ip_type).to be :ipv6
    end

    context "use_ipv4/use_ipv6: nil" do
      before(:each) do
        @use_ipv4 = nil
        @use_ipv6 = nil
      end

      it "return ip_type via enable_ipv4?/enable_ipv6?" do
        if enable_ipv4? && enable_ipv6?
          ip_type = :all
        elsif enable_ipv4?
          ip_type = :ipv4
        elsif enable_ipv6?
          ip_type = :ipv6
        end

        expect(Ddig::Ip.new(use_ipv4: @use_ipv4, use_ipv6: @use_ipv6).ip_type).to be ip_type
      end
    end
  end
end
