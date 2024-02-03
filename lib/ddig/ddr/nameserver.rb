module Ddig
  class Ddr
    class Nameserver
      attr_reader :target, :protocol, :port, :dohpath, :address, :ip

      PROTOCOLS = ['http/1.1', 'h2', 'h3', 'dot', 'doq']

      def initialize(target:, protocol: nil, port: nil, dohpath: nil, address: nil, ip: nil)
        @target = target
        @protocol = protocol
        @port = port
        @dohpath = dohpath
        @address = address
        @ip = ip

        # check protocol
        unless PROTOCOLS.include?(@protocol)
          p "Not Supportted Protocol (#{@protocol})"
        end

        if @port.nil?
          set_default_port
        end
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
    end
  end
end
