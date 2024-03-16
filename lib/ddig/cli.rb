require "optparse"

require "ddig"

module Ddig
  class Cli
    def initialize(args)
      @args = args
      @options = {
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

        opts.on("--nameserver=ipaddress", "nameserver ip address") { |v| @options[:nameserver] = v }
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
      @ddig = Ddig.lookup(@hostname, nameservers: [@options[:nameserver]])

      if @options[:format] == 'json'
        # TODO: to_json
        puts @ddig
      else
        print_result
      end
    end

    def print_result
      puts @ddig
    end
  end
end
