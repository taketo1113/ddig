require 'openssl'
require 'resolv'

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
        message = dns_message(hostname, typeclass)

        request = [message.encode.length].pack('n') + message.encode
        ssl_socket.write(request)

        # recive answer
        len = ssl_socket.read(2).unpack1('n')
        response = Resolv::DNS::Message.decode(ssl_socket.read(len))

        resources = response.answer.map { |name, ttl, resource| resource }

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
