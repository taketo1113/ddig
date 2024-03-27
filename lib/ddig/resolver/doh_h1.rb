require 'net/http'
require 'resolv'
require 'base64'

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
        message = dns_message(hostname, typeclass)
        request = [message.encode.length].pack('n') + message.encode

        path_with_query = @dohpath.gsub('{?dns}', '?dns=' + Base64.urlsafe_encode64(message.encode, padding: false))

        http_response = Net::HTTP.start(@server, @port, use_ssl: true) do |http|
          unless @address.nil?
            http.ipaddr = @address
          end
          header = {}
          header['Accept'] = 'application/dns-message'
          #http.open_timeout = @open_timeout

          http.get(path_with_query, header)
        end

        # recive answer
        response = Resolv::DNS::Message.decode(http_response.body)

        resources = response.answer.map { |name, ttl, resource| resource }

        resources
      end

      def dns_message(hostname, typeclass)
        if hostname.nil?
          return nil
        end
        if typeclass.nil?
          return nil
        end

        message = Resolv::DNS::Message.new
        message.rd = 1 # recursive query
        message.add_question(hostname, typeclass)

        message
      end
    end
  end
end
