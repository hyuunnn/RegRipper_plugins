package breadzip;
use strict;

my %config = (hive          => "NTUSER\.DAT",
              hasShortDescr => 1,
              hasDescr      => 0,
              hasRefs       => 0,
              osmask        => 22,
              version       => 20201201);

sub getConfig{return %config}
sub getShortDescr {
    return "breadzip"
}
sub getDescr{}
sub getRefs {}
sub getHive {return $config{hive};}
sub getVersion {return $config{version};}

sub pluginmain {
    my $class = shift;
    my $hive = shift;
    ::logMsg("[*] Launching breadzip v.".getVersion());
    my $reg = Parse::Win32Registry->new($hive);
    my $root_key = $reg->get_root_key;
    my $key;

    my $key_path = "SOFTWARE\\BreadZip\\4.0\\Reopen";

    if ($key = $root_key->get_subkey($key_path)) {
        ::rptMsg("[-] ".$key_path);
		::rptMsg("LastWrite Time ".::getDateFromEpoch($key->get_timestamp())."Z");

        my @vals = $key->get_list_of_values();
        if (scalar(@vals) > 0) {
            foreach my $v (@vals) {
                ::rptMsg($v->get_name()." : ".$v->get_data());
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