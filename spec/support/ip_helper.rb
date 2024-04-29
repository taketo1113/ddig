module Ddig
  module Ipv6Helper
    def enable_ipv4?
      Ddig::Ip.enable_ipv4?
    end

    def enable_ipv6?
      Ddig::Ip.enable_ipv6?
    end
  end
end
