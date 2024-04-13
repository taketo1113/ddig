require 'resolv'

module Ddig
  module Resolver
    class DnsMessage
      def self.encode(hostname, typeclass)
        if hostname.nil?
          return nil
        end
        if typeclass.nil?
          return nil
        end

        message = Resolv::DNS::Message.new
        message.rd = 1 # recursive query
        message.add_question(hostname, typeclass)

        message.encode
      end

      def self.decode(payload)
        if payload.nil?
          return nil
        end

        Resolv::DNS::Message.decode(payload)
      end

      def self.getresources(payload)
        if payload.nil?
          return []
        end

        response = self.decode(payload)

        return response.answer.map { |name, ttl, resource| resource }
      end
    end
  end
end
