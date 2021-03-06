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

## Log file format

Network statuses are logged to file in CSV format.  
Each entry consists of the following fields, in order from first to last:

- time - the UTC date and time of the log entry.
- localhost status - the status of the localhost connection. `T` = up, `F` = down.
- default gateway status - the status of the connection to the default gateway. `T` = up, `F` = down.
- internet status - the status of the connection to the internet. `T` = up, `F` = down.

## Requirements

- Linux system with ping command, or Windows system
- Elixir 1.10

## Usage

**Running with `mix run`:**  
The configuration file is read from the application/project directory.

**Standalone build with `mix release`:**  
  Releases are built to `_build/MIX_ENV/rel/network_monitor`.  
  The configuration file is read from the release directory.  
  Please see the `mix release` documentation for more information on releases.
