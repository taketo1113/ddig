require "openssl"
require 'net/protocol'

module Ddig
  class Ddr
    class VerifyCert
      attr_reader :hostname, :address, :port, :unencrypted_resolver
      attr_reader :verify, :subject_alt_name, :error_message

      def initialize(hostname:, address:, port:, unencrypted_resolver:)
        @hostname = hostname
        @address = address
        @port = port
        @unencrypted_resolver = unencrypted_resolver

        @open_timeout = 3
      end

      def verify
        begin
          socket = Timeout.timeout(@open_timeout) {
            TCPSocket.open(@address, @port)
          }

          ctx = OpenSSL::SSL::SSLContext.new
          ctx.verify_hostname = true
          #ctx.verify_mode = OpenSSL::SSL::VERIFY_PEER

          ssl_socket = OpenSSL::SSL::SSLSocket.new(socket, ctx)
          ssl_socket.sync_close = true
          ssl_socket.hostname = @hostname

          # connect
          Timeout.timeout(@open_timeout) {
            ssl_socket.connect
          }

          # verify
          set_subject_alt_name(ssl_socket)

          unless ssl_socket.post_connection_check(@hostname)
            @verify = false
            return @verify
          end

          unless ssl_socket.post_connection_check(@unencrypted_resolver)
            @verify = false
            return @verify
          end

          @verify = true
          return @verify

        rescue => e
          @verify = false
          @error_message = e.message

          return @verify
        end
      end

      def set_subject_alt_name(ssl_socket)
        socket = Net::BufferedIO.new(ssl_socket)

        @subject_alt_name = socket.io.peer_cert.extensions.select { |ext| ext.to_h['oid'] == 'subjectAltName' }.first.to_h['value'].split(', ')
      end
    end
  end
end
