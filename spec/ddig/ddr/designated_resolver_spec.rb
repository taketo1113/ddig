# frozen_string_literal: true

RSpec.describe Ddig::Ddr::DesignatedResolver do
  context "set attributes" do
    context "set default port" do
      it "return default port with protocol: http/1.1" do
        @designated_resolver = Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: '8.8.8.8', target: 'dns.google', protocol: 'http/1.1', port: nil, dohpath: nil, address: '8.8.4.4', ip: :ipv4)

        expect(@designated_resolver.port).to eq 443
      end

      it "return default port with protocol: h2" do
        @designated_resolver = Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: '8.8.8.8', target: 'dns.google', protocol: 'h2', port: nil, dohpath: nil, address: '8.8.4.4', ip: :ipv4)

        expect(@designated_resolver.port).to eq 443
      end

      it "return default port with protocol: h3" do
        @designated_resolver = Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: '8.8.8.8', target: 'dns.google', protocol: 'h3', port: nil, dohpath: nil, address: '8.8.4.4', ip: :ipv4)

        expect(@designated_resolver.port).to eq 443
      end

      it "return default port with protocol: dot" do
        @designated_resolver = Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: '8.8.8.8', target: 'dns.google', protocol: 'dot', port: nil, dohpath: nil, address: '8.8.4.4', ip: :ipv4)

        expect(@designated_resolver.port).to eq 853
      end

      it "return default port with protocol: doq" do
        @designated_resolver = Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: '8.8.8.8', target: 'dns.google', protocol: 'doq', port: nil, dohpath: nil, address: '8.8.4.4', ip: :ipv4)

        expect(@designated_resolver.port).to eq 853
      end
    end

    it "return port with args of port" do
      @designated_resolver = Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: '8.8.8.8', target: 'dns.google', protocol: 'h2', port: 8080, dohpath: nil, address: '8.8.4.4', ip: :ipv4)

      expect(@designated_resolver.port).to eq 8080
    end

    it "raise error with invalid protocol" do
      @designated_resolver = Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: '8.8.8.8', target: 'dns.google', protocol: 'invalid', port: nil, dohpath: nil, address: '8.8.4.4', ip: :ipv4)

      expect(@designated_resolver.errors.size).to eq 1
    end
  end

  context "#verify" do
    it "set verify_cert" do
      @designated_resolver = Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: '8.8.8.8', target: 'dns.google', protocol: 'h2', port: nil, dohpath: nil, address: '8.8.4.4', ip: :ipv4)
      @designated_resolver.verify

      expect(@designated_resolver.verify_cert.verify).to eq true
    end

    it "not set verify_cert without verify" do
      @designated_resolver = Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: '8.8.8.8', target: 'dns.google', protocol: 'h2', port: nil, dohpath: nil, address: '8.8.4.4', ip: :ipv4)

      expect(@designated_resolver.verify_cert).to eq nil
    end
  end

  context "#as_json" do
    before(:each) do
      @designated_resolver = Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: '8.8.8.8', target: 'dns.google', protocol: 'dot', port: nil, dohpath: nil, address: '8.8.4.4', ip: :ipv4)
      @designated_resolver.lookup('dns.google')
    end

    it "return values" do
      expect(@designated_resolver.as_json[:unencrypted_resolver]).to eq "8.8.8.8"
      expect(@designated_resolver.as_json[:target]).to eq "dns.google"
      expect(@designated_resolver.as_json[:protocol]).to eq "dot"
      expect(@designated_resolver.as_json[:port]).to eq 853
      expect(@designated_resolver.as_json[:dohpath]).to eq nil
      expect(@designated_resolver.as_json[:address]).to eq "8.8.4.4"
      expect(@designated_resolver.as_json[:ip]).to eq :ipv4
      expect(@designated_resolver.as_json[:verify]).to eq nil
      expect(@designated_resolver.as_json[:hostname]).to eq "dns.google"

      # a
      expect(@designated_resolver.as_json[:a]).to include "8.8.8.8"
      expect(@designated_resolver.as_json[:a]).to include "8.8.4.4"

      # aaaa
      expect(@designated_resolver.as_json[:aaaa]).to include "2001:4860:4860::8844"
      expect(@designated_resolver.as_json[:aaaa]).to include "2001:4860:4860::8888"

      expect(@designated_resolver.as_json[:errors]).to eq []
    end
  end

  context "#to_json" do
    before(:each) do
      @designated_resolver = Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: '8.8.8.8', target: 'dns.google', protocol: 'dot', port: nil, dohpath: nil, address: '8.8.4.4', ip: :ipv4)
      @designated_resolver.lookup('dns.google')
    end

    it "return values" do
      # unencrypted_resolver
      expect(@designated_resolver.to_json).to include '8.8.8.8'

      # target
      expect(@designated_resolver.to_json).to include "dns.google"

      # protocol
      expect(@designated_resolver.to_json).to include "dot"

      # port
      expect(@designated_resolver.to_json).to include '853'

      # address
      expect(@designated_resolver.to_json).to include "8.8.4.4"

      # ip
      expect(@designated_resolver.to_json).to include 'ipv4'

      # hostname
      expect(@designated_resolver.to_json).to include "dns.google"

      # a
      expect(@designated_resolver.to_json).to include "8.8.8.8"
      expect(@designated_resolver.to_json).to include "8.8.4.4"

      # aaaa
      expect(@designated_resolver.to_json).to include "2001:4860:4860::8844"
      expect(@designated_resolver.to_json).to include "2001:4860:4860::8888"
    end
  end
end
