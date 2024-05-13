# ddig

ddig is DNS lookup utility for Ruby.

## Features

- DNS Resolvers
  - UDP (Do53)
  - DoT (DNS over TLS)
    - https://www.rfc-editor.org/rfc/rfc7858.html
  - DoH (DNS over HTTPS)
    - Support only HTTP/1.1
    - https://www.rfc-editor.org/rfc/rfc8484.html
  - ~~DoQ (DNS over QUIC)~~
    - Not Supported
    - https://www.rfc-editor.org/rfc/rfc9250.html
- DDR (Discovery of Designated Resolvers)
  - https://www.rfc-editor.org/rfc/rfc9462.html

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add ddig

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install ddig

## Usage
### Ruby

```ruby
ddig = Ddig.lookup('dns.google', nameservers: ['8.8.8.8', '2001:4860:4860::8888'])

ddig[:do53][:ipv4]
=> #<Ddig::Resolver::Do53:0x00000001207aaeb0 @a=["8.8.4.4", "8.8.8.8"], @aaaa=["2001:4860:4860::8844", "2001:4860:4860::8888"], @hostname="dns.google", @ip=:ipv4, @nameservers=["8.8.8.8"]>
ddig[:do53][:ipv6]
=> #<Ddig::Resolver::Do53:0x000000012073d2c0 @a=["8.8.4.4", "8.8.8.8"], @aaaa=["2001:4860:4860::8844", "2001:4860:4860::8888"], @hostname="dns.google", @ip=:ipv4, @nameservers=["2001:4860:4860::8888"]>

ddig[:ddr]
=> [#<Ddig::Ddr::DesignatedResolver:0x0000000120735480
    @address="8.8.8.8",
    @dohpath=nil,
    @ip=:ipv4,
    @port=853,
    @protocol="dot",
    @target="dns.google",
    @unencrypted_resolver="8.8.8.8",
    @verify_cert=
     #<Ddig::Ddr::VerifyCert:0x00000001207321e0
      @address="8.8.8.8",
      @hostname="dns.google",
      @open_timeout=3,
      @port=853,
      @subject_alt_name=
       ["DNS:dns.google",
        "IP Address:8.8.8.8",
        "IP Address:2001:4860:4860:0:0:0:0:8888",
		...
        "IP Address:2001:4860:4860:0:0:0:0:64"],
      @unencrypted_resolver="8.8.8.8",
      @verify=true>>,
   #<Ddig::Ddr::DesignatedResolver:0x0000000120733b30
    @address="8.8.8.8",
    @dohpath="/dns-query{?dns}",
    @ip=:ipv4,
    @port=443,
    @protocol="h2",
    @target="dns.google",
    @unencrypted_resolver="8.8.8.8",
    @verify_cert=
     #<Ddig::Ddr::VerifyCert:0x0000000120451bd8
      @address="8.8.8.8",
      @hostname="dns.google",
      @open_timeout=3,
      @port=443,
      @subject_alt_name=
       ["DNS:dns.google",
        "IP Address:8.8.8.8",
        "IP Address:2001:4860:4860:0:0:0:0:8888",
		...
        "IP Address:2001:4860:4860:0:0:0:0:64"],
      @unencrypted_resolver="8.8.8.8",
      @verify=true>>,
   ...
]
```

- Do53
```ruby
do53 = Ddig::Resolver::Do53.new(hostname: 'dns.google', nameservers: '8.8.8.8').lookup
=> #<Ddig::Resolver::Do53:0x0000000121717b78 @a=["8.8.8.8", "8.8.4.4"], @aaaa=["2001:4860:4860::8844", "2001:4860:4860::8888"], @hostname="dns.google", @ip=nil, @nameserver=#<Ddig::Nameserver:0x00000001211fb108 @nameservers="8.8.8.8", @servers=["8.8.8.8"]>, @nameservers=["8.8.8.8"]>

do53.a
=> ["8.8.4.4", "8.8.8.8"]
do53.aaaa
=> ["2001:4860:4860::8844", "2001:4860:4860::8888"]
```

- DoT
```ruby
dot = Ddig::Resolver::Dot.new(hostname: 'dns.google', server: '8.8.8.8').lookup
=> #<Ddig::Resolver::Dot:0x000000012145da90 @a=["8.8.8.8", "8.8.4.4"], @aaaa=["2001:4860:4860::8844", "2001:4860:4860::8888"], @hostname="dns.google", @open_timeout=3, @port=853, @server="8.8.8.8", @server_name=nil>

dot.a
=> ["8.8.4.4", "8.8.8.8"]
dot.aaaa
=> ["2001:4860:4860::8844", "2001:4860:4860::8888"]
```

- DoH (HTTP/1.1)
```ruby
doh = Ddig::Resolver::DohH1.new(hostname: 'dns.google', server: 'dns.google', dohpath: '/dns-query{?dns}').lookup
=> #<Ddig::Resolver::DohH1:0x00000001023ed020 @a=["8.8.4.4", "8.8.8.8"], @aaaa=["2001:4860:4860::8888", "2001:4860:4860::8844"], @address=nil, @dohpath="/dns-query{?dns}", @hostname="dns.google", @open_timeout=10, @port=443, @server="dns.google">

doh.a
=> ["8.8.4.4", "8.8.8.8"]
doh.aaaa
=> ["2001:4860:4860::8844", "2001:4860:4860::8888"]
```

### CLI
- Usage
```
$ ddig --help
Usage: ddig [options] hostname
    -d, --dns-type={all|do53|dot}    resolve type (default: all)
        --udp                        use resolve type of udp(do53)
        --dot                        use resolve type of dot
        --doh-h1                     use resolve type of doh (http/1.1)
        --doh-path=doh-path          doh service path
        --ddr                        discover designated resolvers via ddr (discovery of designated resolvers)
    -4, --ipv4                       use IPv4 query transport only
    -6, --ipv6                       use IPv6 query transport only
    -@ipaddress|doh-hostname,        nameserver
        --nameserver
    -p, --port=port                  port
        --format={text|json}         output format (default: text)

    -v, --verbose                    run verbosely
    -h, --help                       show this help message.
        --version                    show version.
```

```sh
$ ddig --nameserver 8.8.8.8 dns.google
# Do53 (IPv4)
dns.google	A	8.8.4.4
dns.google	A	8.8.8.8
dns.google	AAAA	2001:4860:4860::8844
dns.google	AAAA	2001:4860:4860::8888

# SERVER: 8.8.8.8

# DDR
## DDR (#0) - dot: dns.google:853 (8.8.4.4),	unencrypted_resolver: 8.8.8.8, 	verify cert: true
dns.google	A	8.8.4.4
dns.google	A	8.8.8.8
dns.google	AAAA	2001:4860:4860::8844
dns.google	AAAA	2001:4860:4860::8888

# SERVER(Address): 8.8.4.4
# PORT: 853

...

# SERVER(Address): 2001:4860:4860::8888
# PORT: 853

## DDR (#6) - h2: dns.google:443 (2001:4860:4860::8888),	path: /dns-query{?dns},	unencrypted_resolver: 8.8.8.8, 	verify cert: true
dns.google	A	8.8.8.8
dns.google	A	8.8.4.4
dns.google	AAAA	2001:4860:4860::8844
dns.google	AAAA	2001:4860:4860::8888

# SERVER(Hostname): 2001:4860:4860::8888
# SERVER(Path): /dns-query{?dns}
# PORT: 443
...
```

- UDP(Do53)
```sh
$ ddig --udp --nameserver 8.8.8.8 dns.google
dns.google	A	8.8.8.8
dns.google	A	8.8.4.4
dns.google	AAAA	2001:4860:4860::8844
dns.google	AAAA	2001:4860:4860::8888

# SERVER: 8.8.8.8
```

- DoT
```sh
$ ddig --dot --nameserver 8.8.8.8 dns.google
dns.google	A	8.8.8.8
dns.google	A	8.8.4.4
dns.google	AAAA	2001:4860:4860::8888
dns.google	AAAA	2001:4860:4860::8844

# SERVER(Address): 8.8.8.8
# PORT: 853
```

- DoH (HTTP/1.1)
```sh
$ ddig --doh-h1 --nameserver dns.google --doh-path /dns-query{?dns} dns.google
dns.google	A	8.8.8.8
dns.google	A	8.8.4.4
dns.google	AAAA	2001:4860:4860::8888
dns.google	AAAA	2001:4860:4860::8844

# SERVER(Hostname): dns.google
# SERVER(Path): /dns-query{?dns}
# PORT: 443
```

- DDR (Discovery of Designated Resolvers)
```sh
$ ddig --ddr --nameserver 8.8.8.8
dot: dns.google:853 (8.8.8.8),	unencrypted_resolver: 8.8.8.8, 	verify cert: true
dot: dns.google:853 (8.8.4.4),	unencrypted_resolver: 8.8.8.8, 	verify cert: true
dot: dns.google:853 (2001:4860:4860::8844),	unencrypted_resolver: 8.8.8.8, 	verify cert: true
dot: dns.google:853 (2001:4860:4860::8888),	unencrypted_resolver: 8.8.8.8, 	verify cert: true
h2: dns.google:443 (8.8.8.8),	path: /dns-query{?dns},	unencrypted_resolver: 8.8.8.8, 	verify cert: true
h2: dns.google:443 (8.8.4.4),	path: /dns-query{?dns},	unencrypted_resolver: 8.8.8.8, 	verify cert: true
h2: dns.google:443 (2001:4860:4860::8844),	path: /dns-query{?dns},	unencrypted_resolver: 8.8.8.8, 	verify cert: true
h2: dns.google:443 (2001:4860:4860::8888),	path: /dns-query{?dns},	unencrypted_resolver: 8.8.8.8, 	verify cert: true
h3: dns.google:443 (8.8.4.4),	path: /dns-query{?dns},	unencrypted_resolver: 8.8.8.8, 	verify cert: true
h3: dns.google:443 (8.8.8.8),	path: /dns-query{?dns},	unencrypted_resolver: 8.8.8.8, 	verify cert: true
h3: dns.google:443 (2001:4860:4860::8888),	path: /dns-query{?dns},	unencrypted_resolver: 8.8.8.8, 	verify cert: true
h3: dns.google:443 (2001:4860:4860::8844),	path: /dns-query{?dns},	unencrypted_resolver: 8.8.8.8, 	verify cert: true

# SERVER: 8.8.8.8
```

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/taketo1113/ddig.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
