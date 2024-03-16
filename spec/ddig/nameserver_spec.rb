# frozen_string_literal: true

RSpec.describe Ddig::Nameserver do
  context "#servers" do
    it "return nameservers with namesevers" do
      @nameserver = Ddig::Nameserver.new(nameservers: ['8.8.8.8'])

      expect(@nameserver.servers).to eq ['8.8.8.8']
    end

    it "return nameservers with string value of namesevers" do
      @nameserver = Ddig::Nameserver.new(nameservers: '8.8.8.8')

      expect(@nameserver.servers).to eq ['8.8.8.8']
    end

    it "return default nameservers without namesevers" do
      @nameserver = Ddig::Nameserver.new()

      expect(@nameserver.servers.count).not_to eq 0
    end

    it "return default nameservers with nil value of namesevers" do
      @nameserver = Ddig::Nameserver.new(nameservers: nil)

      expect(@nameserver.servers.count).not_to eq 0
    end

    it "raise error when nameservers is blank" do
      @nameserver = Ddig::Nameserver.new(nameservers: [])

      expect{
        @nameserver.servers
      }.to raise_error(Ddig::Error)
    end

    context "with invalid value of namesevers" do
      it "return only valid nameservers with valid and invalid value of nameservers" do
        @nameserver = Ddig::Nameserver.new(nameservers: ['invalid', '8.8.8.8'])

        expect(@nameserver.servers).to eq ['8.8.8.8']
      end

      it "raise error when nameservers is blank" do
        @nameserver = Ddig::Nameserver.new(nameservers: ['invalid'])

        expect{
          @nameserver.servers
        }.to raise_error(Ddig::Error)
      end
    end
  end
end
