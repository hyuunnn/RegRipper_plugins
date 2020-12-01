package enterprise_architect;
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
    return "enterprise_architect"
}
sub getDescr{}
sub getRefs {}
sub getHive {return $config{hive};}
sub getVersion {return $config{version};}

sub pluginmain {
    my $class = shift;
    my $hive = shift;
    ::logMsg("[*] Launching enterprise_architect v.".getVersion());
    my $reg = Parse::Win32Registry->new($hive);
    my $root_key = $reg->get_root_key;
    my $key;

    my $key_path = "SOFTWARE\\Sparx Systems\\EA400\\EA\\RecentFiles";

    if ($key = $root_key->get_subkey($key_path)) {
        ::rptMsg("[-] ".$key_path);
		::rptMsg("LastWrite Time ".::getDateFromEpoch($key->get_timestamp())."Z");

        my $data = $key->get_value("ModelHistory")->get_data();
        my @dataList = split("\xFF\xFE\xFF", $data);
        splice @dataList, 0, 1;
        ::rptMsg("[-] ConnectionItem");
        foreach my $v (@dataList) {
            my $length = ord(substr($v,0,1));
            my $path = substr($v, 1, $length * 2);
            ::rptMsg(Encode::decode("UTF-16LE", $path));
        }
    }
    else {
        ::rptMsg("[-] ".$key_path." not found.");
    }
    ::rptMsg("");
}