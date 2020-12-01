package ezpdf;
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
    return "ezpdf"
}
sub getDescr{}
sub getRefs {}
sub getHive {return $config{hive};}
sub getVersion {return $config{version};}

sub pluginmain {
    my $class = shift;
    my $hive = shift;
    ::logMsg("[*] Launching ezpdf v.".getVersion());
    my $reg = Parse::Win32Registry->new($hive);
    my $root_key = $reg->get_root_key;
    my $key;

    my @paths = ("SOFTWARE\\UNIDOCS\\ezPDF Editor3.0\\Recent File List",
    "SOFTWARE\\UNIDOCS\\ezPDF Editor3.0\\OpenFileList");

    foreach my $key_path (@paths) {
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
}