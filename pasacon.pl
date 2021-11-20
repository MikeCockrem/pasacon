# Alpha test code
# M. Cockrem 2021 mike(at)afk47(dot)org
#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use diagnostics;
use Net::Ping;
use Net::SSH qw(sshopen2);    # https://metacpan.org/pod/Net::SSH
use Net::SSH::Perl;
use POSIX qw(strftime);

my @inarray;
my @merged;
my @array1;
my @array2;
my @array3;
my @host = ( "wiki.afk47.org", "workbench.afk47.org", "fakehost.afk47.org" );
my @deadarray;
my $FH0;
my $fLineCnt = "0";
my $p;
my $user = "mike";
my $command = "uptime|sed \'s/.*up \\([^,]*\\), .*/\\1/\'|tr -d '\\n' && yum -q check-update >/dev/null 2>&1";
my $file = "/mnt/c/Users/mike/OneDrive/Desktop/test.html";
my $date = strftime "%F %H:%M", localtime;
my $quiet = "0";

## Main ##

if ( $quiet == "1" ) {
open (my $STDOLD, '>&', STDOUT);
open (my $STERR, '>&', STDERR);
open (STDERR, '>', '/dev/null');
open (STDERR, '>', '/dev/null');
}

&PingTest();
&PrintData();

## Subroutines ##

sub PingTest {
    foreach (@host) {
        $p = Net::Ping->new("syn");
        if ( $p->ping($_) ) {
            &GetData();
        }
        else {
            push( @deadarray, $_ );
        }
    }
    $p->close();

}

sub GetData {
    my $value1 = "$_";
    my $ssh    = Net::SSH::Perl->new($_);
    $ssh->login($user);
    my ( $out, $err, $exit ) = $ssh->cmd($command);

    #print "$_\n"; 	#
    #print "$out\n";	# Debugging
    #print "$exit\n";	#

    push( @array1, $_ );
    push( @array2, $out );
    if ( $exit == '100' ) {
        push( @array3, "<td style=\"background-color: #ff9900\">Updates Pending</td>"
        );

        # print "Debugging: Got code $exit should be 100\n";
    }
    elsif ( $exit == '0' ) {
        push( @array3, "<td style=\"background-color: #00ff77\">Patched</td>" );

        # print "Debugging: Got code $exit should be 0\n";
    }
    else {
        push( @array3, "<td style=\"background-color: #ff0000\">ERROR!</td>" );

      #print "Debugging: Got code $exit should be 1 or anything but 100 or 0\n";
    }

    @merged = ( \@array1, \@array2, \@array3 );

}

sub PrintData {

    open( FH, '>>', $file ) or die $!;

    print FH "Content-type: text/html\n\n";
    print FH <<"EOF";
    <HTML>
    <HEAD>
        <TITLE>Pasacon host report</TITLE>
    </HEAD>
    <style>
        table, th, td {
            border: 1px solid black;
            border-collapse: collapse;
        }
        th, td {
            padding: 5px;
        }
        th {
            text-align: left;
        }
    </style>
    <BODY>
        <H1>Report Data:</H1>
	<H2>Generated $date</H2>
	<table>
        <tr>
            <th>Host</th>
            <th>Uptime</th>
            <th>Patch Status</th>
        </tr>
EOF
    foreach my $i ( 0 .. $#{ $merged[0] } ) {
        print FH (
            "<tr><td>",  $merged[0][$i], "</td><td>", $merged[1][$i],
             $merged[2][$i], "</tr>\n"
        
    );
    }
    if (@deadarray) {
        foreach (@deadarray) {
            print FH (
            "<tr><td>", $_, 
            "</td><td colspan=2, style=\"background-color: #ff0000\">",
            "OFFLINE", "</td></tr>\n"
            );
        }
    }

    print FH "</table>\n";
    print FH "</body>\n</html>";

    close(FH);
}
