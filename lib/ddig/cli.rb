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

        opts.on("-d", "--dns-type={all|do53|dot}", "resolve type (default: all)") { |v| @options[:dns_type] = v }
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

      unless @hostname.nil?
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

      if @options[:ddr]
        resolve_ddr
      end
    end

    def resolve_all
      @ddig = Ddig.lookup(@hostname, nameservers: @options[:nameserver], use_ipv4: @use_ipv4, use_ipv6: @use_ipv6)

      if @options[:format] == 'json'
        # TODO: to_json
        puts @ddig
      else
        puts @ddig
      end
    end

    def resolve_do53
      ip = Ddig::Ip.new(use_ipv4: @use_ipv4, use_ipv6: @use_ipv6)
      do53 = Ddig::Resolver::Do53.new(hostname: @hostname, nameservers: @options[:nameserver], ip: ip.ip_type).lookup

      if do53.nil?
        puts "Error: Could not lookup wit nameserver: #{@options[:nameserver]}"
        exit
      end

      do53.a.each do |address|
        rr_type = 'A'
        puts "#{@hostname}\t#{rr_type}\t#{address}"
      end
      do53.aaaa.each do |address|
        rr_type = 'AAAA'
        puts "#{@hostname}\t#{rr_type}\t#{address}"
      end

      puts
      puts "# SERVER: #{do53.nameservers.join(', ')}"
    end

    def resolve_dot
      dot = Ddig::Resolver::Dot.new(hostname: @hostname, server: @options[:nameserver], port: @options[:port]).lookup

      dot.a.each do |address|
        rr_type = 'A'
        puts "#{@hostname}\t#{rr_type}\t#{address}"
      end
      dot.aaaa.each do |address|
        rr_type = 'AAAA'
        puts "#{@hostname}\t#{rr_type}\t#{address}"
      end

      puts
      puts "# SERVER(Address): #{dot.server}"
      #puts "# SERVER(Hostname): #{dot.server_name}"
      puts "# PORT: #{dot.port}"
    end

    def resolve_doh_h1
      if @options[:nameserver].nil? || @options[:doh_path].nil?
        puts 'ddig: doh needs option of --doh-path=doh-path'
        exit
      end

      doh = Ddig::Resolver::DohH1.new(hostname: @hostname, server: @options[:nameserver], dohpath: @options[:doh_path], port: @options[:port]).lookup

      doh.a.each do |address|
        rr_type = 'A'
        puts "#{@hostname}\t#{rr_type}\t#{address}"
      end
      doh.aaaa.each do |address|
        rr_type = 'AAAA'
        puts "#{@hostname}\t#{rr_type}\t#{address}"
      end

      puts
      puts "# SERVER(Hostname): #{doh.server}"
      puts "# SERVER(Path): #{doh.dohpath}"
      puts "# PORT: #{doh.port}"
    end

    def resolve_ddr
      ip = Ddig::Ip.new(use_ipv4: @use_ipv4, use_ipv6: @use_ipv6)
      ddr = Ddig::Ddr.new(nameservers: @options[:nameserver], ip: ip.ip_type)

      ddr.designated_resolvers.each_with_index do |designated_resolver, index|
        if ['http/1.1', 'h2', 'h3'].include?(designated_resolver.protocol)
          puts "#{designated_resolver.protocol}: #{designated_resolver.target}:#{designated_resolver.port} (#{designated_resolver.address}),\tpath: #{designated_resolver.dohpath},\tunencrypted_resolver: #{designated_resolver.unencrypted_resolver}, \tverify cert: #{designated_resolver.verify}"
        else
          puts "#{designated_resolver.protocol}: #{designated_resolver.target}:#{designated_resolver.port} (#{designated_resolver.address}),\tunencrypted_resolver: #{designated_resolver.unencrypted_resolver}, \tverify cert: #{designated_resolver.verify}"
        end
      end

      puts
      puts "# SERVER: #{ddr.nameservers.join(', ')}"
    end
  end
end
