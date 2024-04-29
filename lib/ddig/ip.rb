# frozen_string_literal: true

module Ddig
  class Ip
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
