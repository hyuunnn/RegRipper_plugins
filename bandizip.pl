package bandizip;
use strict;
use Encode::Unicode;

my %config = (hive          => "NTUSER\.DAT",
              hasShortDescr => 1,
              hasDescr      => 0,
              hasRefs       => 0,
              osmask        => 22,
              version       => 20201201);

sub getConfig{return %config}
sub getShortDescr {
    return "bandizip"
}
sub getDescr{}
sub getRefs {}
sub getHive {return $config{hive};}
sub getVersion {return $config{version};}

sub pluginmain {
    my $class = shift;
    my $hive = shift;
    ::logMsg("[*] Launching bandizip v.".getVersion());
    my $reg = Parse::Win32Registry->new($hive);
    my $root_key = $reg->get_root_key;
    my $key;

    my $key_path = "SOFTWARE\\Bandizip";

    if ($key = $root_key->get_subkey($key_path)) {
        ::rptMsg("[-] ".$key_path);
		::rptMsg("LastWrite Time ".::getDateFromEpoch($key->get_timestamp())."Z");

        my @vals = $key->get_list_of_values();
        if (scalar(@vals) > 0) {
            foreach my $v (@vals) {
                my $name = uc($v->get_name());
                if ($name =~ m/RECENTARCHIVE([0-9]+)/) {
                    ::rptMsg($v->get_name()." : ".$v->get_data());
                }
                elsif ($name =~ m/RECENTFOLDER([0-9]+)/) {
                    ::rptMsg($v->get_name()." : ".$v->get_data());
                }
            }
        }
        else {
            ::rptMsg("[-] ".$key_path." found, has no values.");
        }
    }
    else {
        ::rptMsg("[-] ".$key_path." not found.");
    }
    ::rptMsg("");
}