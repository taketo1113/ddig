require 'net/http'
require 'resolv'
require 'base64'

require_relative 'dns_message'

module Ddig
  module Resolver
    # DNS over HTTPS (HTTP/1.1)
    class DohH1
      attr_reader :hostname, :server, :address, :dohpath, :port
      attr_reader :a, :aaaa

      def initialize(hostname:, server:, address: nil, dohpath:, port: 443)
        @hostname = hostname
        @server = server
        @address = address
        @dohpath = dohpath
        @port = port || 443

        @open_timeout = 10
      end

      def lookup
        if @server.nil?
          return nil
        end

        @a = get_resources(@hostname, Resolv::DNS::Resource::IN::A).map { |resource| resource.address.to_s if resource.is_a?(Resolv::DNS::Resource::IN::A) }.compact

        @aaaa = get_resources(@hostname, Resolv::DNS::Resource::IN::AAAA).map { |resource| resource.address.to_s if resource.is_a?(Resolv::DNS::Resource::IN::AAAA) }.compact

        self
      end

      def get_resources(hostname, typeclass)
        # send query
        payload = DnsMessage.encode(hostname, typeclass)

        path_with_query = @dohpath.gsub('{?dns}', '?dns=' + Base64.urlsafe_encode64(payload, padding: false))

        http_response = Net::HTTP.start(@server, @port, use_ssl: true, ipaddr: @address) do |http|
          header = {}
          header['Accept'] = 'application/dns-message'
          #http.open_timeout = @open_timeout

          http.get(path_with_query, header)
        end

        # recive answer
        resources = DnsMessage.getresources(http_response.body)

        resources
      end
    end
  end
end
