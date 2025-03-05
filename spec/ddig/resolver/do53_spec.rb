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

    it "https return values" do
      @do53 = Ddig::Resolver::Do53.new(hostname: 'ddig-https.taketoketa.org')
      @do53.lookup

      expect(@do53.https).to include({ priority: 1, target: ".", alpn: ["h3", "h2"] })
      expect(@do53.https).to include({ priority: 2, target: "test.taketoketa.org", alpn: ["h3", "h2"] })
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

    it "https return values" do
      @do53 = Ddig::Resolver::Do53.new(hostname: 'ddig-https.taketoketa.org', nameservers: @nameservers)
      @do53.lookup

      expect(@do53.https).to include({ priority: 1, target: ".", alpn: ["h3", "h2"] })
      expect(@do53.https).to include({ priority: 2, target: "test.taketoketa.org", alpn: ["h3", "h2"] })
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
    end

    it "raise Error" do
      expect {
        @do53 = Ddig::Resolver::Do53.new(hostname: 'dns.google', nameservers: @nameservers)
        #@do53.lookup
      }.to raise_error(Ddig::Error)
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

    it "https return values" do
      @do53 = Ddig::Resolver::Do53.new(hostname: 'ddig-https.taketoketa.org', ip: @ip, nameservers: @nameservers)
      @do53.lookup

      expect(@do53.https).to include({ priority: 1, target: ".", alpn: ["h3", "h2"] })
      expect(@do53.https).to include({ priority: 2, target: "test.taketoketa.org", alpn: ["h3", "h2"] })
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
      skip 'IPv6 is not available' unless enable_ipv6?

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

    it "https return values" do
      @do53 = Ddig::Resolver::Do53.new(hostname: 'ddig-https.taketoketa.org', ip: @ip, nameservers: @nameservers)
      @do53.lookup

      expect(@do53.https).to include({ priority: 1, target: ".", alpn: ["h3", "h2"] })
      expect(@do53.https).to include({ priority: 2, target: "test.taketoketa.org", alpn: ["h3", "h2"] })
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

  context "#as_json" do
    before(:each) do
      @do53 = Ddig::Resolver::Do53.new(hostname: 'dns.google')
      @do53.lookup
    end

    it "a/aaaa return values" do
      # a
      expect(@do53.as_json[:a]).to include "8.8.8.8"
      expect(@do53.as_json[:a]).to include "8.8.4.4"

      # aaaa
      expect(@do53.as_json[:aaaa]).to include "2001:4860:4860::8844"
      expect(@do53.as_json[:aaaa]).to include "2001:4860:4860::8888"
    end

    it "https return values" do
      @do53 = Ddig::Resolver::Do53.new(hostname: 'ddig-https.taketoketa.org')
      @do53.lookup

      expect(@do53.as_json[:https]).to include({ priority: 1, target: ".", alpn: ["h3", "h2"] })
      expect(@do53.as_json[:https]).to include({ priority: 2, target: "test.taketoketa.org", alpn: ["h3", "h2"] })
    end

    it "hostname set value" do
      expect(@do53.as_json[:hostname]).to eq 'dns.google'
    end

    it "nameservers set values" do
      expect(@do53.as_json[:nameservers]).not_to eq nil
    end

    it "ip is nil" do
      expect(@do53.as_json[:ip]).to eq nil
    end
  end

  context "#to_json" do
    before(:each) do
      @do53 = Ddig::Resolver::Do53.new(hostname: 'dns.google')
      @do53.lookup
    end

    it "a/aaaa return values" do
      # a
      expect(@do53.to_json).to include "8.8.8.8"
      expect(@do53.to_json).to include "8.8.4.4"

      # aaaa
      expect(@do53.to_json).to include "2001:4860:4860::8844"
      expect(@do53.to_json).to include "2001:4860:4860::8888"
    end

    it "hostname set value" do
      expect(@do53.to_json).to include 'dns.google'
    end
  end

  context "#to_cli" do
    before(:each) do
      @do53 = Ddig::Resolver::Do53.new(hostname: 'dns.google')
      @do53.lookup
    end

    it "a/aaaa return values" do
      # a
      expect { @do53.to_cli }.to output(/8.8.8.8/).to_stdout
      expect { @do53.to_cli }.to output(/8.8.4.4/).to_stdout

      # aaaa
      expect { @do53.to_cli }.to output(/2001:4860:4860::8888/).to_stdout
      expect { @do53.to_cli }.to output(/2001:4860:4860::8844/).to_stdout
    end
  end
end
