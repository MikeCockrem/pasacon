For when you want to manage servers like it's the 90s again

This Perl script connects via SSH to a list of remote servers
(as many or few as you like) and grabs their uptime and queries
if they have any updates pending, then it spits out a 'nice' 
HTML summary that you can email or upload to a server.

Run it manually, run it on a cron, marvel at it's slow speed.
Supports RHEL and RHEL-like Linux or any Linux that uses YUM.

Requires:
- Perl 5
- Net::SSH::Perl
- Net::Ping

