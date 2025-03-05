# frozen_string_literal: true

RSpec.describe Ddig::Resolver::DohH1 do
  context "#lookup" do
    before(:each) do
      @doh = Ddig::Resolver::DohH1.new(hostname: 'dns.google', server: 'dns.google', dohpath: '/dns-query{?dns}')
      @doh.lookup
    end

    it "a/aaaa return values" do
      # a
      expect(@doh.a).to include "8.8.8.8"
      expect(@doh.a).to include "8.8.4.4"

      # aaaa
      expect(@doh.aaaa).to include "2001:4860:4860::8844"
      expect(@doh.aaaa).to include "2001:4860:4860::8888"
    end

    it "https return values" do
      @doh = Ddig::Resolver::DohH1.new(hostname: 'ddig-https.taketoketa.org', server: 'dns.google', dohpath: '/dns-query{?dns}')
      @doh.lookup

      expect(@doh.https).to include({ priority: 1, target: ".", alpn: ["h3", "h2"] })
      expect(@doh.https).to include({ priority: 2, target: "test.taketoketa.org", alpn: ["h3", "h2"] })
    end
  end

  context "#lookup: with server (ipv4) / address" do
    before(:each) do
      @doh = Ddig::Resolver::DohH1.new(hostname: 'dns.google', server: 'dns.google', address: '8.8.8.8', dohpath: '/dns-query{?dns}')
      @doh.lookup
    end

    it "a/aaaa return values" do
      # a
      expect(@doh.a).to include "8.8.8.8"
      expect(@doh.a).to include "8.8.4.4"

      # aaaa
      expect(@doh.aaaa).to include "2001:4860:4860::8844"
      expect(@doh.aaaa).to include "2001:4860:4860::8888"
    end

    it "https return values" do
      @doh = Ddig::Resolver::DohH1.new(hostname: 'ddig-https.taketoketa.org', server: 'dns.google', dohpath: '/dns-query{?dns}')
      @doh.lookup

      expect(@doh.https).to include({ priority: 1, target: ".", alpn: ["h3", "h2"] })
      expect(@doh.https).to include({ priority: 2, target: "test.taketoketa.org", alpn: ["h3", "h2"] })
    end
  end

  context "#lookup: with server (ipv6) / address" do
    before(:each) do
      skip 'IPv6 is not available' unless enable_ipv6?

      @doh = Ddig::Resolver::DohH1.new(hostname: 'dns.google', server: 'dns.google', address: '2001:4860:4860::8888', dohpath: '/dns-query{?dns}')
      @doh.lookup
    end

    it "a/aaaa return values" do
      # a
      expect(@doh.a).to include "8.8.8.8"
      expect(@doh.a).to include "8.8.4.4"

      # aaaa
      expect(@doh.aaaa).to include "2001:4860:4860::8844"
      expect(@doh.aaaa).to include "2001:4860:4860::8888"
    end

    it "https return values" do
      @doh = Ddig::Resolver::DohH1.new(hostname: 'ddig-https.taketoketa.org', server: 'dns.google', address: '2001:4860:4860::8888', dohpath: '/dns-query{?dns}')
      @doh.lookup

      expect(@doh.https).to include({ priority: 1, target: ".", alpn: ["h3", "h2"] })
      expect(@doh.https).to include({ priority: 2, target: "test.taketoketa.org", alpn: ["h3", "h2"] })
    end
  end

  context "#lookup: with invalid address" do
    before(:each) do
      @doh = Ddig::Resolver::DohH1.new(hostname: 'dns.google', server: 'example.com', address: '8.8.8.8', dohpath: '/dns-query{?dns}')
    end

    it "raise Error" do
      expect {
        @doh.lookup
      }.to raise_error(StandardError)
      # ruby2.7+: OpenSSL::SSL::SSLError: certificate verify failed (hostname mismatch)
      # ruby2.6: Net::HTTPServerException: 404 "Not Found"
    end
  end

  context "set port attribute" do
    it "return default port without port" do
      @doh = Ddig::Resolver::DohH1.new(hostname: 'dns.google', server: 'dns.google', dohpath: '/dns-query{?dns}')

      expect(@doh.port).to eq 443
    end

    it "return default port wit nil value of port" do
      @doh = Ddig::Resolver::DohH1.new(hostname: 'dns.google', server: 'dns.google', dohpath: '/dns-query{?dns}', port: nil)

      expect(@doh.port).to eq 443
    end

    it "return port with port value" do
      @doh = Ddig::Resolver::DohH1.new(hostname: 'dns.google', server: 'dns.google', dohpath: '/dns-query{?dns}', port: 8443)

      expect(@doh.port).to eq 8443
    end
  end

  context "#as_json" do
    before(:each) do
      @doh = Ddig::Resolver::DohH1.new(hostname: 'dns.google', server: 'dns.google', dohpath: '/dns-query{?dns}')
      @doh.lookup
    end

    it "a/aaaa return values" do
      # a
      expect(@doh.as_json[:a]).to include "8.8.8.8"
      expect(@doh.as_json[:a]).to include "8.8.4.4"

      # aaaa
      expect(@doh.as_json[:aaaa]).to include "2001:4860:4860::8844"
      expect(@doh.as_json[:aaaa]).to include "2001:4860:4860::8888"
    end

    it "https return values" do
      @doh = Ddig::Resolver::DohH1.new(hostname: 'ddig-https.taketoketa.org', server: 'dns.google', dohpath: '/dns-query{?dns}')
      @doh.lookup

      expect(@doh.as_json[:https]).to include({ priority: 1, target: ".", alpn: ["h3", "h2"] })
      expect(@doh.as_json[:https]).to include({ priority: 2, target: "test.taketoketa.org", alpn: ["h3", "h2"] })
    end

    it "hostname set value" do
      expect(@doh.as_json[:hostname]).to eq 'dns.google'
    end

    it "server set value" do
      expect(@doh.as_json[:server]).to eq 'dns.google'
    end

    it "address set nil" do
      expect(@doh.as_json[:address]).to eq nil
    end

    it "dohpath set value" do
      expect(@doh.as_json[:dohpath]).to eq '/dns-query{?dns}'
    end

    it "port set value" do
      expect(@doh.as_json[:port]).to eq 443
    end
  end

  context "#to_json" do
    before(:each) do
      @doh = Ddig::Resolver::DohH1.new(hostname: 'dns.google', server: 'dns.google', dohpath: '/dns-query{?dns}')
      @doh.lookup
    end

    it "a/aaaa return values" do
      # a
      expect(@doh.to_json).to include "8.8.8.8"
      expect(@doh.to_json).to include "8.8.4.4"

      # aaaa
      expect(@doh.to_json).to include "2001:4860:4860::8844"
      expect(@doh.to_json).to include "2001:4860:4860::8888"
    end

    it "hostname set value" do
      expect(@doh.to_json).to include 'dns.google'
    end

    it "dohpath set value" do
      expect(@doh.to_json).to include '/dns-query{?dns}'
    end

    it "port set value" do
      expect(@doh.to_json).to include '443'
    end
  end

  context "#to_cli" do
    before(:each) do
      @doh = Ddig::Resolver::DohH1.new(hostname: 'dns.google', server: 'dns.google', dohpath: '/dns-query{?dns}')
      @doh.lookup
    end

    it "a/aaaa return values" do
      # a
      expect { @doh.to_cli }.to output(/8.8.8.8/).to_stdout
      expect { @doh.to_cli }.to output(/8.8.4.4/).to_stdout

      # aaaa
      expect { @doh.to_cli }.to output(/2001:4860:4860::8888/).to_stdout
      expect { @doh.to_cli }.to output(/2001:4860:4860::8844/).to_stdout
    end

    it "hostname return values" do
      expect { @doh.to_cli }.to output(/dns.google/).to_stdout
    end

    it "dohpath return values" do
      expect { @doh.to_cli }.to output(/\/dns-query{\?dns}/).to_stdout
    end

    it "port return values" do
      expect { @doh.to_cli }.to output(/443/).to_stdout
    end
  end
end
