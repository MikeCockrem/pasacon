# Alpha test code
# M. Cockrem 2021 mike(at)afk47(dot)org
#!/usr/bin/perl
use strict;
use warnings FATAL => 'all';
use diagnostics;
use Net::Ping;
use Net::SSH qw(sshopen3); # https://metacpan.org/pod/Net::SSH

my @inarray;
my @merged;
my @array1;
my @array2;
my @host = ("testhost");
my $FH0;
my $fLineCnt="0";
my $p;
my $user="mike";
my $command = "uptime|sed \'s/.*up \\([^,]*\\), .*/\\1/\'";
my $command2 = "yum -q check-update"; # Ideally we need to catch code 0 for nothing 100 for something and 1 for error

# Main
&PingTest();
#&PrintData();

sub PingTest {
    foreach (@host) {
        $p = Net::Ping->new("syn");
        if($p->ping($_)) {
            #&GetData();
            &test();
        }else{
            print "$_ is not alive\n";
        }
    }
    $p->close();

}

sub test {
    my $value1 = "$_";
    sshopen3("$user\@$_", *READER, *WRITER, "$command2");
    sleep(5);
    #if(defined $error);{
    #print "HELP! $error\n";
    #}

    while (<READER>) {
        chomp();
        print "Return Code: $_\n";
    }
}

sub GetData {
    my $value1 = "$_";

    sshopen2("$user\@$_", *READER, *WRITER, "$command");

    while (<READER>) {
        chomp();
        push(@array1, $value1);
        push(@array2, $_);
    }

    @merged = (\@array1, \@array2);

    close(READER);
    close(WRITER);
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
        </tr>
EOF
    foreach my $i (0..$#{$merged[0]}) {
        print ("<tr><td>",$merged[0][$i],"</td><td>",$merged[1][$i],"</td>\n</tr>");
    }

    print "</table>\n";
    print "</body>\n</html>";
}
