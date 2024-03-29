module Ddig
  class Ddr
    class DesignatedResolver
      attr_reader :unencrypted_resolver, :target, :protocol, :port, :dohpath, :address, :ip
      attr_reader :verify_cert

      PROTOCOLS = ['http/1.1', 'h2', 'h3', 'dot', 'doq']

      def initialize(unencrypted_resolver:, target:, protocol: nil, port: nil, dohpath: nil, address: nil, ip: nil)
        @target = target
        @unencrypted_resolver = unencrypted_resolver
        @protocol = protocol
        @port = port
        @dohpath = dohpath
        @address = address
        @ip = ip

        # check protocol
        unless PROTOCOLS.include?(@protocol)
          raise Error.new("Not Supportted Protocol (protocol: #{@protocol}). Suported protocol is #{PROTOCOLS.join(' / ')}")
        end

        if @port.nil?
          set_default_port
        end
      end

      def verify
        @verify_cert = VerifyCert.new(hostname: @target, address: @address, port: @port, unencrypted_resolver: @unencrypted_resolver)
        @verify_cert.verify
      end

      # Set default port by protocol
      # ref: https://www.rfc-editor.org/rfc/rfc9461.html#section-4.2
      def set_default_port
        case @protocol
        when 'http/1.1'
          @port = 80
        when 'h2', 'h3'
          @port = 443
        when 'dot', 'doq'
          @port = 853
        end
      end

      def uniq_key
        "#{@unencrypted_resolver}-#{@target}-#{@protocol}-#{@port}-#{@dohpath}-#{@address}-#{@ip}"
      end
    end
  end
end
