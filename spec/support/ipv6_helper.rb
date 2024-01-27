module Ddig
  module Ipv6Helper
    def enable_ipv6?
      Socket.ip_address_list.each do |addrinfo|
        if RUBY_VERSION < '3.1'
          # for ipaddr gem <= v1.2.2, Not support zone identifiers in IPv6 addresses
          addr = IPAddr.new(addrinfo.ip_address.split('%').first)
        else
          addr = IPAddr.new(addrinfo.ip_address)
        end

        if addr.ipv6? && !addr.loopback? && !addr.link_local?
          return true
        end
      end

      return false
    end
  end
end
