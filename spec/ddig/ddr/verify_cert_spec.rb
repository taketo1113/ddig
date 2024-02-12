# frozen_string_literal: true

RSpec.describe Ddig::Ddr::VerifyCert do
  context "#verify" do
    context ":ipv4" do
      it "return true with valid cert" do
        @verify_cert = Ddig::Ddr::VerifyCert.new(hostname: 'dns.google', address: '8.8.4.4', port: 443, unencrypted_resolver: '8.8.8.8')

        expect(@verify_cert.verify).to eq true
      end

      it "return true with valid cert and hostname is ipaddress" do
        @verify_cert = Ddig::Ddr::VerifyCert.new(hostname: '8.8.4.4', address: '8.8.4.4', port: 443, unencrypted_resolver: '8.8.8.8')

        expect(@verify_cert.verify).to eq true
      end

      it "return false with invalid address" do
        @verify_cert = Ddig::Ddr::VerifyCert.new(hostname: 'dns.google', address: 'invalid', port: 443, unencrypted_resolver: '8.8.8.8')

        expect(@verify_cert.verify).to eq false
      end

      it "return false with invalid unencrypted_resolver address not include cert san" do
        @verify_cert = Ddig::Ddr::VerifyCert.new(hostname: 'dns.google', address: '8.8.4.4', port: 443, unencrypted_resolver: '1.1.1.1')

        expect(@verify_cert.verify).to eq false
      end
    end

    context ":ipv6" do
      before(:each) do
        skip 'IPv6 is not available' unless enable_ipv6?
      end

      it "return true with valid cert" do
        @verify_cert = Ddig::Ddr::VerifyCert.new(hostname: 'dns.google', address: '2001:4860:4860:0:0:0:0:8844', port: 443, unencrypted_resolver: '2001:4860:4860:0:0:0:0:8888')

        expect(@verify_cert.verify).to eq true
      end

      it "return true with valid cert and hostname is ipaddress" do
        @verify_cert = Ddig::Ddr::VerifyCert.new(hostname: '8.8.4.4', address: '2001:4860:4860:0:0:0:0:8844', port: 443, unencrypted_resolver: '2001:4860:4860:0:0:0:0:8888')

        expect(@verify_cert.verify).to eq true
      end

      it "return false with invalid address" do
        @verify_cert = Ddig::Ddr::VerifyCert.new(hostname: 'dns.google', address: 'invalid', port: 443, unencrypted_resolver: '2001:4860:4860:0:0:0:0:8888')

        expect(@verify_cert.verify).to eq false
      end

      it "return false with invalid unencrypted_resolver address not include cert san" do
        @verify_cert = Ddig::Ddr::VerifyCert.new(hostname: 'dns.google', address: '2001:4860:4860:0:0:0:0:8844', port: 443, unencrypted_resolver: '2606:4700:4700::1111')

        expect(@verify_cert.verify).to eq false
      end
    end
  end
end
