# frozen_string_literal: true

RSpec.describe Ddig::Resolver::Do53 do
  context "#lookup" do
    before(:each) do
      @do53 = Ddig::Resolver::Do53.new(hostname: 'dns.google')
      @do53.lookup
    end

    it "a/aaaa return values" do
      # a
      expect(@do53.a).to include "8.8.8.8"
      expect(@do53.a).to include "8.8.4.4"

      # aaaa
      expect(@do53.aaaa).to include "2001:4860:4860::8844"
      expect(@do53.aaaa).to include "2001:4860:4860::8888"
    end

    it "hostname set value" do
      expect(@do53.hostname).to eq 'dns.google'
    end

    it "nameservers set values" do
      expect(@do53.nameservers).not_to eq nil
    end

    it "ip is nil" do
      expect(@do53.ip).to eq nil
    end
  end

  context "#lookup: with nameserver" do
    before(:each) do
      @nameservers = ['8.8.8.8']

      @do53 = Ddig::Resolver::Do53.new(hostname: 'dns.google', nameservers: @nameservers)
      @do53.lookup
    end

    it "a/aaaa return values" do
      # a
      expect(@do53.a).to include "8.8.8.8"
      expect(@do53.a).to include "8.8.4.4"

      # aaaa
      expect(@do53.aaaa).to include "2001:4860:4860::8844"
      expect(@do53.aaaa).to include "2001:4860:4860::8888"
    end

    it "hostname set value" do
      expect(@do53.hostname).to eq 'dns.google'
    end

    it "nameservers set values" do
      expect(@do53.nameservers).to eq ['8.8.8.8']
    end

    it "ip is nil" do
      expect(@do53.ip).to eq nil
    end
  end

  context "#lookup: with invalid nameserver" do
    before(:each) do
      @nameservers = ['invalid']

      @do53 = Ddig::Resolver::Do53.new(hostname: 'dns.google', nameservers: @nameservers)
    end

    it "raise Error" do
      expect {
        @do53.lookup
      }.to raise_error(StandardError) # ruby 3.3+: Socket::ResolutionError, ruby 3.2-: SocketError
    end
  end

  context "#lookup: ipv4" do
    before(:each) do
      @ip = :ipv4
      @nameservers = ['8.8.8.8', '2001:4860:4860::8888']

      @do53 = Ddig::Resolver::Do53.new(hostname: 'dns.google', ip: @ip, nameservers: @nameservers)
      @do53.lookup
    end

    it "a/aaaa return values" do
      # a
      expect(@do53.a).to include "8.8.8.8"
      expect(@do53.a).to include "8.8.4.4"

      # aaaa
      expect(@do53.aaaa).to include "2001:4860:4860::8844"
      expect(@do53.aaaa).to include "2001:4860:4860::8888"
    end

    it "hostname set value" do
      expect(@do53.hostname).to eq 'dns.google'
    end

    it "nameservers set values" do
      expect(@do53.nameservers).to eq ['8.8.8.8']
    end

    it "ip is nil" do
      expect(@do53.ip).to eq :ipv4
    end
  end

  context "#lookup: ipv6" do
    before(:each) do
      skip unless enable_ipv6?

      @ip = :ipv6
      @nameservers = ['8.8.8.8', '2001:4860:4860::8888']

      @do53 = Ddig::Resolver::Do53.new(hostname: 'dns.google', ip: @ip, nameservers: @nameservers)
      @do53.lookup
    end

    it "a/aaaa return values" do
      # a
      expect(@do53.a).to include "8.8.8.8"
      expect(@do53.a).to include "8.8.4.4"

      # aaaa
      expect(@do53.aaaa).to include "2001:4860:4860::8844"
      expect(@do53.aaaa).to include "2001:4860:4860::8888"
    end

    it "hostname set value" do
      expect(@do53.hostname).to eq 'dns.google'
    end

    it "nameservers set values" do
      expect(@do53.nameservers).to eq ['2001:4860:4860::8888']
    end

    it "ip is nil" do
      expect(@do53.ip).to eq :ipv6
    end
  end
end
