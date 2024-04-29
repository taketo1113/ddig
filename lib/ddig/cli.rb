require "optparse"

require "ddig"

module Ddig
  class Cli
    def initialize(args)
      @args = args
      @options = {
        type: 'all',
        format: 'text',
      }

      parse_options

      if @hostname.nil?
        puts @option_parser
        exit
      end
    end

    def parse_options
      @option_parser = OptionParser.new do |opts|
        opts.banner = "Usage: ddig [options] hostname"

        opts.on("-t", "--type={all|do53|dot}", "resolve type (default: all)") { |v| @options[:type] = v }
        opts.on("--udp", "use resolve type of udp(do53)") { |v| @options[:type] = 'do53' }
        opts.on("--dot", "use resolve type of dot") { |v| @options[:type] = 'dot' }
        opts.on("--doh-h1", "use resolve type of doh (http/1.1)") { |v| @options[:type] = 'doh_h1' }
        opts.on("--doh-path=doh-path", "doh service path") { |v| @options[:doh_path] = v }
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

    def exec
      if @options[:ipv4] || @options[:ipv6]
        @use_ipv4 = @options[:ipv4] || false
        @use_ipv6 = @options[:ipv6] || false
      end

      case @options[:type]
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
  end
end
