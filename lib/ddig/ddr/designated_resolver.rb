require 'json'

module Ddig
  class Ddr
    class DesignatedResolver
      attr_reader :unencrypted_resolver, :target, :protocol, :port, :dohpath, :address, :ip
      attr_reader :verify_cert
      attr_reader :hostname, :a, :aaaa, :resolver, :errors

      PROTOCOLS = ['http/1.1', 'h2', 'h3', 'dot', 'doq']

      def initialize(unencrypted_resolver:, target:, protocol: nil, port: nil, dohpath: nil, address: nil, ip: nil)
        @target = target
        @unencrypted_resolver = unencrypted_resolver
        @protocol = protocol
        @port = port
        @dohpath = dohpath
        @address = address
        @ip = ip
        @errors = []

        # check protocol
        unless PROTOCOLS.include?(@protocol)
          @errors << "Not Supportted Protocol (protocol: #{@protocol}). Suported protocol is #{PROTOCOLS.join(' / ')}"
          puts "#{@errors.join('\n')}"
        end

        if @port.nil?
          set_default_port
        end
      end

      def verify
        @verify_cert = VerifyCert.new(hostname: @target, address: @address, port: @port, unencrypted_resolver: @unencrypted_resolver)
        @verify_cert.verify
      end

      def lookup(hostname)
        @hostname = hostname

        case @protocol
        when 'dot'
          @resolver = Ddig::Resolver::Dot.new(hostname: @hostname, server: @address, server_name: @target, port: @port).lookup

          unless @resolver.nil?
            @a = @resolver.a
            @aaaa = @resolver.aaaa

            return self
          end

        when 'http/1.1', 'h2', 'h3'
          @resolver = Ddig::Resolver::DohH1.new(hostname: @hostname, server: @address, address: @address, dohpath: @dohpath, port: @port).lookup

          unless @resolver.nil?
            @a = @resolver.a
            @aaaa = @resolver.aaaa

            return self
          end

        when 'doq'
          @errors << "#{@protocol} is not supportted protocol"
        end
      end

      def as_json(*)
        {
          unencrypted_resolver: @unencrypted_resolver,
          target: @target,
          protocol: @protocol,
          port: @port,
          dohpath: @dohpath,
          address: @address,
          ip: @ip,
          verify: @verify_cert&.verify,
          hostname: @hostname,
          a: @a,
          aaaa: @aaaa,
          errors: @errors,
        }
      end

      def to_json(*args)
        as_json.to_json
      end

      def to_cli
        if @resolver.nil?
          puts "# #{@errors.join('\n# ')}"
          return
        end

        @resolver.to_cli
      end

      def to_s
        if ['http/1.1', 'h2', 'h3'].include?(@protocol)
          "#{@protocol}: #{@target}:#{@port} (#{@address}),\tpath: #{@dohpath},\tunencrypted_resolver: #{@unencrypted_resolver}, \tverify cert: #{@verify_cert.verify}"
        else
          "#{@protocol}: #{@target}:#{@port} (#{@address}),\tunencrypted_resolver: #{@unencrypted_resolver}, \tverify cert: #{@verify_cert.verify}"
        end
      end

      # Set default port by protocol
      # ref: https://www.rfc-editor.org/rfc/rfc9461.html#section-4.2
      def set_default_port
        case @protocol
        when 'http/1.1', 'h2', 'h3'
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
