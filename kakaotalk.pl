package kakaotalk;
use strict;

my %config = (hive          => "NTUSER\.DAT",
              hasShortDescr => 1,
              hasDescr      => 0,
              hasRefs       => 0,
              osmask        => 22,
              version       => 20201201);

sub getConfig{return %config}
sub getShortDescr {
    return "kakaotalk"
}
sub getDescr{}
sub getRefs {}
sub getHive {return $config{hive};}
sub getVersion {return $config{version};}

sub Update {
    my ($root_key) = @_;
    my $key_path = "SOFTWARE\\Kakao\\KakaoTalk\\Update";

    my $key;
    if ($key = $root_key->get_subkey($key_path)) {
        ::rptMsg("[-] ".$key_path);
		::rptMsg("LastWrite Time ".::getDateFromEpoch($key->get_timestamp())."Z");

        my $data = $key->get_value("patch_txt_LM")->get_data();
        ::rptMsg("patch_txt_LM : ".$data);
        
        my $data = $key->get_value("patch_txt_ETag")->get_data();
        ::rptMsg("patch_txt_ETag : ".$data);
    }
    else {
        ::rptMsg("[-] ".$key_path." not found.");
    }
    ::rptMsg("");
}

sub UserAccounts {
    my ($root_key) = @_;
    my $key_path = "SOFTWARE\\Kakao\\KakaoTalk\\UserAccounts";

    my $key;
    if ($key = $root_key->get_subkey($key_path)) {
        ::rptMsg("[-] ".$key_path);
		::rptMsg("LastWrite Time ".::getDateFromEpoch($key->get_timestamp())."Z");

        my @sk = $key->get_list_of_subkeys();
        if (scalar @sk > 0) {
            foreach my $k (@sk) {
                ::rptMsg($k->get_name());
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

sub pluginmain {
    my $class = shift;
    my $hive = shift;
    ::logMsg("[*] Launching kakaotalk v.".getVersion());
    my $reg = Parse::Win32Registry->new($hive);
    my $root_key = $reg->get_root_key;

    Update($root_key);
    UserAccounts($root_key);
}