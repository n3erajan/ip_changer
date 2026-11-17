# System-wide Tor IP Changer

Temporarily route a Debian or Ubuntu machine's TCP and DNS traffic through Tor.
The tool requests a new Tor identity every three minutes and restores normal
networking when it exits.

## What it does

- Starts an isolated Tor instance without changing your existing Tor settings.
- Redirects new IPv4 TCP connections through Tor with `nftables`.
- Sends IPv4 DNS requests to Tor's DNS resolver.
- Blocks public UDP, ICMP, IPv6, and other traffic that Tor cannot carry.
- Keeps loopback and private LAN destinations reachable directly.
- Requests `NEWNYM` every 180 seconds by default.
- Removes its firewall table before stopping Tor on `Ctrl+C` or `SIGTERM`.

> Tor may select the same exit again. `NEWNYM` requests a new circuit but does
> not guarantee a different public IP. Existing TCP connections may continue on
> their old circuit; new connections use the new circuit.

## Supported systems

- Debian
- Ubuntu
- A system using `nftables`

The installer and runtime commands require root access because they install
packages and temporarily change the machine's output firewall.

> Run the tool from a local terminal, not over SSH. Activation intentionally
> blocks existing public connections, including the SSH session controlling it.

## Install

```bash
git clone https://github.com/n3erajan/ip_changer
cd ip_changer
chmod +x install.sh
sudo ./install.sh
```

The installer uses `apt` to install Tor, nftables, Stem, Requests, and SOCKS
support. It then installs the command as `/usr/local/bin/ip-changer`.

No Tor password or manual `/etc/tor/torrc` editing is required. The program uses
a separate Tor instance with cookie authentication and non-default ports.

## Use

Start a foreground session:

```bash
sudo ip-changer start
```

Press **Ctrl+C** in that terminal to stop. The firewall rules are removed first,
then the temporary Tor instance is stopped.

Useful commands:

```bash
# See whether routing is active
sudo ip-changer status

# Request a new Tor circuit immediately
sudo ip-changer new-identity

# Stop a session from another terminal
sudo ip-changer stop

# Remove stale rules after a crash or forced termination
sudo ip-changer restore
```

Change the rotation interval, for example to five minutes:

```bash
sudo ip-changer start --interval 300
# Short form:
sudo ip-changer start -i 300
```

The minimum accepted interval is 30 seconds. The default is 180 seconds.

## Recovery and safety

Normal exits, `Ctrl+C`, and termination signals trigger automatic cleanup. No
program can run cleanup after `SIGKILL`, a kernel crash, or sudden power loss. If
networking is unavailable after such an event, run:

```bash
sudo ip-changer restore
```

If the Python command itself cannot run, the direct firewall-only recovery is:

```bash
sudo nft delete table inet tor_ip_changer_managed
```

The firewall configuration is kept in a dedicated nftables table named
`inet tor_ip_changer_managed`. Cleanup deletes only that table; it does not flush
or replace the machine's other firewall rules.

While active, software that requires public UDP, ICMP, inbound public replies,
or IPv6 will not work. Private IPv4 LAN connections remain direct and are not
anonymized.

Tor logs are written to `/var/log/ip-changer-tor.log` for troubleshooting.
