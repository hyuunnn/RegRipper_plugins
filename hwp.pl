# HWP 2005, 2007, 2010

package hwp;
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
    return "hwp"
}
sub getDescr{}
sub getRefs {}
sub getHive {return $config{hive};}
sub getVersion {return $config{version};}

sub printData {
    my $key;
    my ($root_key, $filter, @paths) = @_;
    foreach my $key_path (@paths) {
        if ($key = $root_key->get_subkey($key_path)) {
            ::rptMsg("[-] ".$key_path);
			::rptMsg("LastWrite Time ".::getDateFromEpoch($key->get_timestamp())."Z");

            my @vals = $key->get_list_of_values();
            if (scalar(@vals) > 0) {
                foreach my $v (@vals) {
                    my $name = uc($v->get_name());
                    if ($name =~ /$filter([0-9]+)/) {
                        ::rptMsg($v->get_name()." : ".Encode::decode("UTF-16LE", $v->get_data()));
                    }
                    else {
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
}

sub pluginmain {
    my $class = shift;
    my $hive = shift;
    ::logMsg("[*] Launching hwp v.".getVersion());
    my $reg = Parse::Win32Registry->new($hive);
    my $root_key = $reg->get_root_key;

    my @paths = ("SOFTWARE\\HNC\\Hwp\\6.5\\RecentFile", 
        "SOFTWARE\\HNC\\Hwp\\7.0\\HwpFrame\\RecentFile",
        "SOFTWARE\\HNC\\Hwp\\8.0\\HwpFrame\\RecentFile");
    printData($root_key, "FILE", @paths);

    my @paths = ("SOFTWARE\\HNC\\Hwp\\FindReplace\\Find");
    printData($root_key, "FIND", @paths);
}