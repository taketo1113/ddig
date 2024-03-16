# frozen_string_literal: true

RSpec.describe Ddig::Resolver::Dot do
  context "#lookup" do
    before(:each) do
      @dot = Ddig::Resolver::Dot.new(hostname: 'dns.google', server: 'dns.google')
      @dot.lookup
    end

    it "a/aaaa return values" do
      # a
      expect(@dot.a).to include "8.8.8.8"
      expect(@dot.a).to include "8.8.4.4"

      # aaaa
      expect(@dot.aaaa).to include "2001:4860:4860::8844"
      expect(@dot.aaaa).to include "2001:4860:4860::8888"
    end
  end

  context "#lookup: with server (ipv4) / server_name" do
    before(:each) do
      @dot = Ddig::Resolver::Dot.new(hostname: 'dns.google', server: '8.8.8.8', server_name: 'dns.google')
      @dot.lookup
    end

    it "a/aaaa return values" do
      # a
      expect(@dot.a).to include "8.8.8.8"
      expect(@dot.a).to include "8.8.4.4"

      # aaaa
      expect(@dot.aaaa).to include "2001:4860:4860::8844"
      expect(@dot.aaaa).to include "2001:4860:4860::8888"
    end
  end

  context "#lookup: with server (ipv6) / server_name" do
    before(:each) do
      skip 'IPv6 is not available' unless enable_ipv6?

      @dot = Ddig::Resolver::Dot.new(hostname: 'dns.google', server: '2001:4860:4860::8888', server_name: 'dns.google')
      @dot.lookup
    end

    it "a/aaaa return values" do
      # a
      expect(@dot.a).to include "8.8.8.8"
      expect(@dot.a).to include "8.8.4.4"

      # aaaa
      expect(@dot.aaaa).to include "2001:4860:4860::8844"
      expect(@dot.aaaa).to include "2001:4860:4860::8888"
    end
  end

  context "#lookup: with invalid server_name" do
    before(:each) do
      @dot = Ddig::Resolver::Dot.new(hostname: 'dns.google', server: '8.8.8.8', server_name: 'example.com')
    end

    it "raise Error" do
      expect {
        @dot.lookup
      }.to raise_error(OpenSSL::SSL::SSLError) # error: certificate verify failed (hostname mismatch)
    end
  end
end
