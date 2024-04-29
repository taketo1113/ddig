# frozen_string_literal: true

module Ddig
  class Ip
    attr_reader :ip_type

    def initialize(use_ipv4: nil, use_ipv6: nil)
      @use_ipv4 = use_ipv4
      @use_ipv6 = use_ipv6

      set_ip_type
    end

    def set_ip_type
      if @use_ipv4.nil? && self.class.enable_ipv4?
        @use_ipv4 = true
      end

      if @use_ipv6.nil? && self.class.enable_ipv6?
        @use_ipv6 = true
      end

      if @use_ipv4 && @use_ipv6
        @ip_type = :all
      elsif @use_ipv4
        @ip_type = :ipv4
      elsif @use_ipv6
        @ip_type = :ipv6
      end
    end

    def self.enable_ipv4?
      ip_list.any? { |addr| addr.ipv4? }
    end

    def self.enable_ipv6?
      ip_list.any? { |addr| addr.ipv6? }
    end

    private

    def self.ip_list
      Socket.ip_address_list.map do |addrinfo|
        if RUBY_VERSION < '3.1'
          # for ipaddr gem <= v1.2.2, Not support zone identifiers in IPv6 addresses
          addr = IPAddr.new(addrinfo.ip_address.split('%').first)
        else
          addr = IPAddr.new(addrinfo.ip_address)
        end

        if !addr.loopback? && !addr.link_local?
          addr
        end
      end.compact
    end
  end
end
