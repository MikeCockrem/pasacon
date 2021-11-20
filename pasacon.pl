# Alpha test code
# M. Cockrem 2021 mike(at)afk47(dot)org
#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use diagnostics;
use Net::Ping;
use Net::SSH qw(sshopen2); # https://metacpan.org/pod/Net::SSH
use Net::SSH::Perl;

my @inarray;
my @merged;
my @array1;
my @array2;
my @array3;
my @host = ("wiki.afk47.org","workbench.afk47.org");
my $FH0;
my $fLineCnt="0";
my $p;
my $user="mike";
my $command = "uptime|sed \'s/.*up \\([^,]*\\), .*/\\1/\'";
my $command2 = "yum -q check-update"; # Ideally we need to catch code 0 for nothing 100 for something and 1 for error
my $command3 = "uptime|sed \'s/.*up \\([^,]*\\), .*/\\1/\'|tr -d '\\n' && yum -q check-update >/dev/null 2>&1";

# Main
&PingTest();
&PrintData();

sub PingTest {
    foreach (@host) {
        $p = Net::Ping->new("syn");
        if($p->ping($_)) {
            &GetData();
        }else{
            print "$_ is not alive\n";
        }
    }
    $p->close();

}

sub GetData {
    my $value1 = "$_";
    my $ssh = Net::SSH::Perl->new($_);
     $ssh->login($user);
     my($out, $err, $exit) = $ssh->cmd($command3);
     print "$_\n";
     print "$out\n";
     print "$exit\n";

     push(@array1, $_);
     push(@array2, $out);
     if($exit == '100') {
	     push(@array3, "<span style=\"background-color: #ff0000\">Updates Pending</span>");
	     print "Got code $exit should be 100\n";
     } elsif($exit == '0') {
	     push(@array3, "<span style=\"background-color: #00ff77\">Patched</span>");
	     print "Got code $exit should be 0\n";
     }else{ 
	     push(@array3, "<span style=\"background-color: #ff9900\">ERROR!</span>");
	     print "Got code $exit should be 1 or anything but 100 or 0\n";
     }

     @merged = (\@array1, \@array2, \@array3);

}

sub PrintData {
    print "Content-type: text/html\n\n";
    print <<"EOF";
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
        <table>
        <tr>
            <th>Host</th>
            <th>Uptime</th>
            <th>Patch Status</th>
        </tr>
EOF
    foreach my $i (0..$#{$merged[0]}) {
        print ("<tr><td>",$merged[0][$i],"</td><td>",$merged[1][$i],"</td><td>",$merged[2][$i],"</tr>\n");
    }

    print "</table>\n";
    print "</body>\n</html>";
}
