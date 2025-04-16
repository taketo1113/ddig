# frozen_string_literal: true

RSpec.describe Ddig::Ddr do
  context "#svcb_records" do
    it "return svcb_records with namesevers" do
      @ddr = Ddig::Ddr.new(nameservers: ['8.8.8.8'])

      expect(@ddr.svcb_records.count).to eq 2
    end

    it "return svcb_records including attributes with namesevers" do
      @ddr = Ddig::Ddr.new(nameservers: ['8.8.8.8'])
      svcb_record = @ddr.svcb_records.first

      expect(svcb_record[:unencrypted_resolver]).to eq '8.8.8.8'
      expect(svcb_record[:svcb_record].class.to_s).to eq 'Resolv::DNS::Resource::IN::SVCB'
      expect(svcb_record[:svcb_record].target.to_s).to eq 'dns.google'
    end

    it "raise error with empty namesevers" do
      expect {
        @ddr = Ddig::Ddr.new(nameservers: [])
      }.to raise_error(Ddig::Error)
    end

    it "raise error with invalid namesevers" do
      expect {
        @ddr = Ddig::Ddr.new(nameservers: 'invalid')
      }.to raise_error(Ddig::Error)
    end
  end

  context "#designated_resolvers" do
    it "return designated_resolvers with namesevers" do
      @ddr = Ddig::Ddr.new(nameservers: ['8.8.8.8'])

      expect(@ddr.designated_resolvers.count).not_to eq 0
    end

    it "return designated_resolvers including attributes with namesevers" do
      @ddr = Ddig::Ddr.new(nameservers: ['8.8.8.8'])
      designated_resolver = @ddr.designated_resolvers.first

      expect(designated_resolver.class.to_s).to eq 'Ddig::Ddr::DesignatedResolver'
      expect(designated_resolver.unencrypted_resolver).to eq '8.8.8.8'
      expect(designated_resolver.target).to eq 'dns.google'
      expect(designated_resolver.verify_cert).not_to eq nil
    end

    it "raise error with empty namesevers" do
      expect {
        @ddr = Ddig::Ddr.new(nameservers: [])
      }.to raise_error(Ddig::Error)
    end

    it "raise error with invalid namesevers" do
      expect {
        @ddr = Ddig::Ddr.new(nameservers: 'invalid')
      }.to raise_error(Ddig::Error)
    end
  end

  context "#as_json" do
    before(:each) do
      @ddr = Ddig::Ddr.new(nameservers: ['8.8.8.8'])
    end

    it "return values of designated_resolvers" do
      @designated_resolvers = @ddr.as_json[:designated_resolvers]
      @designated_resolver = @designated_resolvers.first

      expect(@designated_resolvers).not_to eq nil
      expect(@designated_resolver).not_to eq nil
      expect(@designated_resolver[:unencrypted_resolver]).to eq "8.8.8.8"
      expect(@designated_resolver[:target]).to eq "dns.google"
      expect(@designated_resolver[:protocol]).to eq "dot"
      expect(@designated_resolver[:port]).to eq 853
      expect(@designated_resolver[:dohpath]).to eq nil
      expect(@designated_resolver[:address]).not_to eq nil # "8.8.4.4" or "8.8.8.8"
      expect(@designated_resolver[:ip]).to eq :ipv4
      expect(@designated_resolver[:verify]).to eq true
      expect(@designated_resolver[:hostname]).to eq nil
      expect(@designated_resolver[:a]).to eq nil
      expect(@designated_resolver[:aaaa]).to eq nil
      expect(@designated_resolver[:errors]).to eq []
    end

    it "return values" do
      expect(@ddr.as_json[:hostname]).to eq nil
      expect(@ddr.as_json[:nameservers]).to eq ["8.8.8.8"]
      expect(@ddr.as_json[:ip]).to eq nil
    end
  end

  context "#to_json" do
    before(:each) do
      @ddr = Ddig::Ddr.new(nameservers: ['8.8.8.8'])
    end

    it "return values" do
      expect(@ddr.to_json).to include "8.8.8.8"
      expect(@ddr.to_json).to include "dns.google"
      expect(@ddr.to_json).to include "dot"
      expect(@ddr.to_json).to include '853'
      expect(@ddr.to_json).to include 'ipv4'
      expect(@ddr.to_json).to include 'true'
    end
  end
end
