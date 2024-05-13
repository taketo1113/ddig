require "optparse"

require "ddig"

module Ddig
  class Cli
    def initialize(args)
      @args = args
      @options = {
        dns_type: 'all',
        format: 'text',
      }

      parse_options

      unless valid_options?
        puts @option_parser
        exit
      end
    end

    def parse_options
      @option_parser = OptionParser.new do |opts|
        opts.banner = "Usage: ddig [options] hostname"

        opts.on("-d", "--dns-type={all|do53|dot|doh_h1}", "resolve type (default: all)") { |v| @options[:dns_type] = v }
        opts.on("--udp", "use resolve type of udp(do53)") { |v| @options[:dns_type] = 'do53' }
        opts.on("--dot", "use resolve type of dot") { |v| @options[:dns_type] = 'dot' }
        opts.on("--doh-h1", "use resolve type of doh (http/1.1)") { |v| @options[:dns_type] = 'doh_h1' }
        opts.on("--doh-path=doh-path", "doh service path") { |v| @options[:doh_path] = v }
        opts.on("--ddr", "discover designated resolvers via ddr (discovery of designated resolvers)") { |v| @options[:ddr] = v }
        opts.on("-4", "--ipv4", "use IPv4 query transport only") { |v| @options[:ipv4] = v }
        opts.on("-6", "--ipv6", "use IPv6 query transport only") { |v| @options[:ipv6] = v }
        opts.on("-@", "--nameserver=ipaddress|doh-hostname", "nameserver") { |v| @options[:nameserver] = v }
        opts.on("-p", "--port=port", "port") { |v| @options[:port] = v }
        opts.on("--format={text|json}", "output format (default: text)") { |v| @options[:format] = v }

        opts.separator ""

        opts.on("-v", "--verbose", "run verbosely") { |v| @options[:verbose] = v }

        opts.on("-h", "--help", "show this help message.") { puts opts; exit }
        opts.on("--version", "show version.") { puts Ddig::VERSION; exit }
      end
      @option_parser.parse!

      @hostname = @args[0]
    end

    def valid_options?
      if @hostname.nil?
        if @options[:ddr]
          return true
        end

        return false
      end

      return true
    end

    def exec
      if @options[:ipv4] || @options[:ipv6]
        @use_ipv4 = @options[:ipv4] || false
        @use_ipv6 = @options[:ipv6] || false
      end

      if @options[:ddr]
        resolve_ddr
        exit
      end

      case @options[:dns_type]
      when "all"
        resolve_all
      when "do53"
        resolve_do53
      when "dot"
        resolve_dot
      when "doh_h1"
        resolve_doh_h1
      end
    end

    def resolve_all
      @ddig = Ddig.lookup(@hostname, nameservers: @options[:nameserver], use_ipv4: @use_ipv4, use_ipv6: @use_ipv6)

      if @options[:format] == 'json'
        # TODO: to_json
      else
        unless @ddig[:do53][:ipv4].nil?
          puts "# Do53 (IPv4)"
          @ddig[:do53][:ipv4].to_cli
          puts
        end

        unless @ddig[:do53][:ipv6].nil?
          puts "# Do53 (IPv6)"
          @ddig[:do53][:ipv6].to_cli
          puts
        end

        unless @ddig[:ddr].nil?
          puts "# DDR"
          @ddig[:ddr].each_with_index do |designated_resolver, index|
            puts "## DDR (##{index}) - #{designated_resolver.to_s}"
            designated_resolver.to_cli
            puts
          end
        end
      end
    end

    def resolve_do53
      ip = Ddig::Ip.new(use_ipv4: @use_ipv4, use_ipv6: @use_ipv6)
      do53 = Ddig::Resolver::Do53.new(hostname: @hostname, nameservers: @options[:nameserver], ip: ip.ip_type).lookup

      if do53.nil?
        puts "Error: Could not lookup wit nameserver: #{@options[:nameserver]}"
        exit
      end

      do53.to_cli
    end

    def resolve_dot
      dot = Ddig::Resolver::Dot.new(hostname: @hostname, server: @options[:nameserver], port: @options[:port]).lookup

      dot.to_cli
    end

    def resolve_doh_h1
      if @options[:nameserver].nil? || @options[:doh_path].nil?
        puts 'ddig: doh needs option of --doh-path=doh-path'
        exit
      end

      doh = Ddig::Resolver::DohH1.new(hostname: @hostname, server: @options[:nameserver], dohpath: @options[:doh_path], port: @options[:port]).lookup

      doh.to_cli
    end

    def resolve_ddr
      ip = Ddig::Ip.new(use_ipv4: @use_ipv4, use_ipv6: @use_ipv6)
      ddr = Ddig::Ddr.new(nameservers: @options[:nameserver], ip: ip.ip_type)

      ddr.to_cli
    end
  end
end
