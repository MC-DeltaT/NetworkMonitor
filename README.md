# NetworkMonitor

Periodically logs the status of network connections to file.

## Supported network connections

- IPv4 localhost. Checked via ICMP ping.
- IPv4 default gateway. Checked via ICMP ping.
- IPv4 internet. Checked via creation of a TCP connection to 8.8.8.8 on port 53.

## Configuration

Configuration is done via a `config.json` file in the release (or app) directory.

Configuration fields:

- `log_schedule` - String, required. A crontab expression specifying when network statuses are logged.
- `log_file_path` - String, required. Specifies the file in which network statuses are logged. If a relative path, is taken to be relative to the location of the configuration file.
- `default_gateway` - String, required. Specifies the IPv4 address of the device's default gateway.

## Requirements

- Linux system with ping command, or Windows system
- Elixir 1.10
