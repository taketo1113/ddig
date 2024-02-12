# frozen_string_literal: true

RSpec.describe Ddig::Ddr::DesignatedResolver do
  context "set attributes" do
    context "set default port" do
      it "return default port with protocol: http/1.1" do
        @designated_resolver = Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: '8.8.8.8', target: 'dns.google', protocol: 'http/1.1', port: nil, dohpath: nil, address: '8.8.4.4', ip: :ipv4)

        expect(@designated_resolver.port).to eq 80
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
      expect {
        Ddig::Ddr::DesignatedResolver.new(unencrypted_resolver: '8.8.8.8', target: 'dns.google', protocol: 'invalid', port: nil, dohpath: nil, address: '8.8.4.4', ip: :ipv4)
      }.to raise_error(Ddig::Error)
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
end
