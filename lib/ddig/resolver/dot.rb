require 'openssl'
require 'resolv'

require_relative 'dns_message'

module Ddig
  module Resolver
    # DNS over TLS/TCP
    class Dot
      attr_reader :hostname, :server, :server_name, :port
      attr_reader :a, :aaaa

      def initialize(hostname:, server:, server_name: nil, port: 853)
        @hostname = hostname
        @server = server
        @server_name = server_name
        @port = port || 853

        @open_timeout = 3
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
        ssl_socket = get_socket

        # send query
        payload = DnsMessage.encode(hostname, typeclass)
        request = [payload.length].pack('n') + payload

        ssl_socket.write(request)

        # recive answer
        len = ssl_socket.read(2).unpack1('n')
        resources = DnsMessage.getresources(ssl_socket.read(len))

        resources
      end

      def get_socket
        begin
          socket = Timeout.timeout(@open_timeout) {
            TCPSocket.open(@server, @port)
          }

          ctx = OpenSSL::SSL::SSLContext.new
          ctx.set_params
          ctx.alpn_protocols = ['dot']

          ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ctx)
          ssl_socket.sync_close = true
          unless @server_name.nil?
            ssl_socket.hostname = @server_name
          end

          # connect
          Timeout.timeout(@open_timeout) {
            ssl_socket.connect
            unless @server_name.nil?
              ssl_socket.post_connection_check(@server_name)
            end
          }

          ssl_socket
        end
      end

      def to_cli
        @a.each do |address|
          rr_type = 'A'
          puts "#{@hostname}\t#{rr_type}\t#{address}"
        end
        @aaaa.each do |address|
          rr_type = 'AAAA'
          puts "#{@hostname}\t#{rr_type}\t#{address}"
        end

        puts
        puts "# SERVER(Address): #{@server}"
        #puts "# SERVER(Hostname): #{@server_name}"
        puts "# PORT: #{@port}"
      end
    end
  end
end
