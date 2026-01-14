# RDAP Client

A lightweight, dependency-minimal RDAP (Registration Data Access Protocol) client for Linux. Query domain, IP, and ASN registration data directly from the command line.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)

## Why RDAP?

RDAP is the modern replacement for WHOIS, providing structured JSON responses with better internationalization support and standardized query/response formats. This client makes RDAP queries simple and accessible from any Linux terminal.

## Features

- **Minimal Dependencies** - Requires only `curl` (pre-installed on most Linux systems)
- **Optional Formatting** - Install `jq` for pretty-printed output
- **Auto-Detection** - Automatically detects query type (domain, IP, ASN)
- **40+ Built-in Servers** - Works immediately for common TLDs without configuration
- **Multiple Output Formats** - Brief, full detailed, or raw JSON
- **Registrar Follow** - Fetch complete contact data from registrar RDAP servers
- **Advanced Queries** - Nameserver lookups, entity searches, and more
- **Caching** - IANA bootstrap data cached for 24 hours

---

## Installation

### Quick Install (Recommended)

```bash
# Download the script
sudo curl -fsSL https://raw.githubusercontent.com/Osir-Inc/rdap/main/rdap -o /usr/local/bin/rdap

# Make it executable
sudo chmod +x /usr/local/bin/rdap

# Verify installation
rdap --help
```

### User Installation (No sudo required)

```bash
# Create local bin directory if it doesn't exist
mkdir -p ~/.local/bin

# Download the script
curl -fsSL https://raw.githubusercontent.com/Osir-Inc/rdap/main/rdap -o ~/.local/bin/rdap

# Make it executable
chmod +x ~/.local/bin/rdap

# Add to PATH (add this line to ~/.bashrc or ~/.zshrc for persistence)
export PATH="$HOME/.local/bin:$PATH"

# Verify installation
rdap --help
```

### Install from Source

```bash
# Clone the repository
git clone https://github.com/Osir-Inc/rdap.git
cd rdap

# Option 1: System-wide installation
sudo make install

# Option 2: User installation
make install-user
```

### Install Optional Dependency

For better formatted output, install `jq`:

```bash
# Debian/Ubuntu
sudo apt install jq

# Fedora/RHEL/CentOS
sudo dnf install jq

# Arch Linux
sudo pacman -S jq

# Alpine
sudo apk add jq
```

---

## Usage

### Basic Queries

```bash
# Domain lookup
rdap osir.com

# IP address lookup (IPv4 or IPv6)
rdap 8.8.8.8
rdap 2001:4860:4860::8888

# ASN lookup
rdap AS11867
rdap 11867
```

### Output Formats

```bash
# Brief output (default) - key information only
rdap osir.com

# Full detailed output - all entities, events, notices
rdap -f osir.com

# Raw JSON output - for scripting/parsing
rdap -r osir.com

# Verbose mode - shows debug information
rdap -v osir.com
```

### Using a Specific RDAP Server

```bash
# Query a specific RDAP server
rdap -s https://rdap.osir.com/rdap osir.com

# Query with explicit type
rdap -t domain -s https://rdap.osir.com/rdap osir.com
```

### Registrar Data (-R flag)

Registry servers (like Verisign for .com) return limited data. Use `-R` to automatically follow the registrar link for complete contact information:

```bash
# Registry data only (limited - no contact details)
rdap osir.com

# Follow registrar link for complete data (registrant, tech, admin contacts)
rdap -R osir.com

# Full output from registrar
rdap -R -f osir.com
```

### Advanced Queries

These require specifying an RDAP server with `-s`:

```bash
# Nameserver lookup
rdap -t ns -s https://rdap.verisign.com/com/v1 ns1.osir.com

# Server help/capabilities
rdap -t help -s https://rdap.verisign.com/com/v1

# Entity lookup
rdap -t entity -s https://rdap.arin.net/registry ARIN

# Domain search (with wildcards)
rdap -t domain-search -s https://rdap.verisign.com/com/v1 'osir*.com'

# Domain search by nameserver
rdap -t domain-search-by-ns -s https://rdap.verisign.com/com/v1 ns1.osir.com

# Nameserver search
rdap -t ns-search -s https://rdap.verisign.com/com/v1 'ns*.osir.com'

# Entity search
rdap -t entity-search -s https://rdap.arin.net/registry 'Osir*'
```

---

## Command Reference

```
rdap [OPTIONS] <query>

OPTIONS:
    -t, --type <type>   Specify query type (see Advanced Query Types below)
    -s, --server <url>  Use specific RDAP server URL
    -f, --full          Full detailed output (all entities, events, notices)
    -R, --registrar     Follow registrar link for complete contact data
    -r, --raw           Output raw JSON (for scripting)
    -v, --verbose       Verbose output (debug information)
    -h, --help          Show help message
    --clear-cache       Clear IANA bootstrap cache

BASIC QUERY TYPES (auto-detected):
    domain              Any domain name (e.g., osir.com)
    ip                  IPv4 or IPv6 address (e.g., 8.8.8.8)
    asn                 AS number (e.g., AS11867 or 11867)

ADVANCED QUERY TYPES (require -t and -s flags):
    ns, nameserver                  Nameserver lookup
    help                            Server capabilities
    entity                          Entity/contact lookup
    domain-search                   Search domains by name pattern
    domain-search-by-ns             Search domains by nameserver
    domain-search-by-ns-ip          Search domains by nameserver IP
    ns-search                       Search nameservers by name pattern
    ns-search-by-ip                 Search nameservers by IP
    entity-search                   Search entities by name
    entity-search-by-handle         Search entities by handle
```

---

## Output Examples

### Brief Domain Output (default)

```
$ rdap osir.com

Domain Information
────────────────────────────────────────
Domain:      OSIR.COM
Status:      client transfer prohibited
Created:     1997-03-25T05:00:00Z
Expires:     2027-03-26T04:00:00Z
Updated:     2025-12-03T16:21:53Z
Nameservers:
  NS1.OSIR.COM
  NS3.OSIR.COM
Registrar:   Osir, Inc.
DNSSEC:      Yes
```

### Full Output (-f flag)

```
$ rdap -f osir.com

Domain:
  Domain Name: OSIR.COM
  Handle: 1285453_DOMAIN_COM-VRSN
  Status: client transfer prohibited
  Conformance: rdap_level_0
  Conformance: icann_rdap_technical_implementation_guide_1
  Notice:
    Title: Terms of Service
    Description: Service subject to Terms of Use.
    Link: https://www.verisign.com/domain-names/registration-data-access-protocol/terms-service/index.xhtml
  ...
  Entity:
    Handle: 4332
    Role: registrar
    Public ID:
      Type: IANA Registrar ID
      Identifier: 4332
    vCard Version: 4.0
    vCard Name: Osir, Inc.
  ...
```

### ASN Output

```
$ rdap AS11867

ASN Information
────────────────────────────────────────
Handle:      AS11867
ASN:         11867
Name:        EASYSTREET-AS
Status:      active
Country:     US
```

### Raw JSON Output (-r flag)

```bash
$ rdap -r osir.com | jq '.nameservers[].ldhName'
"NS1.OSIR.COM"
"NS3.OSIR.COM"
```

---

## Common RDAP Servers

| TLD/Region | Server URL |
|------------|------------|
| .com, .net | https://rdap.verisign.com/com/v1 |
| .org | https://rdap.publicinterestregistry.org/rdap |
| .io | https://rdap.nic.io |
| .co | https://rdap.nic.co |
| ARIN (Americas) | https://rdap.arin.net/registry |
| RIPE (Europe) | https://rdap.db.ripe.net |
| APNIC (Asia-Pacific) | https://rdap.apnic.net |
| LACNIC (Latin America) | https://rdap.lacnic.net/rdap |
| AFRINIC (Africa) | https://rdap.afrinic.net/rdap |

---

## Environment & Files

| Item | Location |
|------|----------|
| Cache directory | `~/.cache/rdap/` (or `$XDG_CACHE_HOME/rdap/`) |
| Cache TTL | 24 hours |
| Bootstrap data | Fetched from IANA when TLD not in built-in list |

---

## Troubleshooting

### "command not found: rdap"

The installation directory is not in your PATH:

```bash
# Check where rdap is installed
which rdap || find /usr -name rdap 2>/dev/null

# Add to PATH temporarily
export PATH="/usr/local/bin:$PATH"

# Or for user installation
export PATH="$HOME/.local/bin:$PATH"
```

### "No RDAP server found for TLD"

The TLD is not in the built-in list and IANA bootstrap failed:

```bash
# Solution 1: Specify server manually
rdap -s https://rdap.nic.tld example.tld

# Solution 2: Clear cache and retry
rdap --clear-cache
rdap osir.com
```

### Limited output / Missing contact information

Registry data is often limited. Use `-R` to fetch from the registrar:

```bash
rdap -R osir.com
```

### Debug connection issues

Use verbose mode:

```bash
rdap -v osir.com
```

---

## Comparison with Alternatives

| Feature | rdap (this) | whois | rdap-client (Go) |
|---------|-------------|-------|------------------|
| Dependencies | curl only | whois package | Go runtime |
| Install size | ~55 KB | varies | ~10 MB |
| Structured output | JSON | Plain text | JSON |
| Offline TLD support | 40+ TLDs | No | Yes |
| Install time | Seconds | Package manager | Minutes (compile) |

---

## Building Packages

See [BUILDING.md](BUILDING.md) for instructions on creating:
- Debian/Ubuntu packages (.deb)
- RPM packages (Fedora/RHEL/CentOS)
- Alpine packages (APK)

---

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

## Credits

Developed by [Osir, Inc.](https://osir.com) - ICANN Accredited Domain Registrar (IANA #4332)

## See Also

- [RDAP Protocol (RFC 7480-7484)](https://tools.ietf.org/html/rfc7480)
- [IANA RDAP Bootstrap](https://data.iana.org/rdap/)
- [ICANN RDAP Information](https://www.icann.org/rdap)
