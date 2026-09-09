require 'resolv'

module Ddig
  module Resolver
    class DnsResourceHttps
      attr_reader :priority, :target, :alpn, :port, :ipv4hint, :ipv6hint

      def self.build(resources)
        resources
          .select { |resource| resource.is_a?(Resolv::DNS::Resource::IN::HTTPS) }
          .map { |resource| new(resource) }
          .sort_by { |https| https.priority }
      end

      def initialize(resource)
        @priority = resource.priority
        @target = resource.target != Resolv::DNS::Name.create(".") ? resource.target.to_s : "."

        @alpn = resource.params[:alpn]&.protocol_ids
        @port = resource.params[:port]&.port
        @ipv4hint = resource.params[:ipv4hint]&.addresses&.map(&:to_s)
        @ipv6hint = resource.params[:ipv6hint]&.addresses&.map(&:to_s)
      end

      def as_json(*)
        {
          priority: @priority,
          target: @target,
          alpn: @alpn,
          port: @port,
          ipv4hint: @ipv4hint,
          ipv6hint: @ipv6hint,
        }
      end

      def to_json(*args)
        as_json.to_json
      end
    end
  end
end
