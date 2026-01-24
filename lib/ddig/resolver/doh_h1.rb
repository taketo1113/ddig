require 'net/http'
require 'resolv'
require 'base64'
require 'json'

require_relative 'dns_message'

module Ddig
  module Resolver
    # DNS over HTTPS (HTTP/1.1)
    class DohH1
      attr_reader :hostname, :server, :address, :dohpath, :port
      attr_reader :a, :aaaa, :https

      def initialize(hostname:, server:, address: nil, dohpath: '/dns-query{?dns}', port: 443)
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

        @https = get_resources(@hostname, Resolv::DNS::Resource::IN::HTTPS).map do |resource|
          { priority: resource.priority, target: resource.target != Resolv::DNS::Name.create(".") ? resource.target.to_s : '.' , alpn: resource.params[:alpn].protocol_ids } if resource.is_a?(Resolv::DNS::Resource::IN::HTTPS)
        end.compact

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

        case http_response
        when Net::HTTPSuccess
          # recive answer
          return DnsMessage.getresources(http_response.body)
        else
          http_response.value
          return []
        end
      end

      def as_json(*)
        {
          a: @a,
          aaaa: @aaaa,
          https: @https,
          hostname: @hostname,
          server: @server,
          address: @address,
          dohpath: @dohpath,
          port: @port,
        }
      end

      def to_json(*args)
        as_json.to_json
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
        @https.each do |record|
          rr_type = 'HTTPS'
          puts "#{@hostname}\t#{rr_type}\tpriority: #{record[:priority]}\ttarget: #{record[:target]}\talpn: #{record[:alpn].join(', ')}"
        end

        puts
        puts "# SERVER(Hostname): #{@server}"
        puts "# SERVER(Path): #{@dohpath}"
        puts "# PORT: #{@port}"
      end
    end
  end
end
