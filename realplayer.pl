package realplayer;
use strict;
use Time::Local;

my %config = (hive          => "NTUSER\.DAT",
              hasShortDescr => 1,
              hasDescr      => 0,
              hasRefs       => 0,
              osmask        => 22,
              version       => 20201206);

sub getConfig{return %config}
sub getShortDescr {
    return "realplayer"
}
sub getDescr{}
sub getRefs {}
sub getHive {return $config{hive};}
sub getVersion {return $config{version};}

sub pluginmain {
    my $class = shift;
    my $hive = shift;
    ::logMsg("[*] Launching realplayer v.".getVersion());
    my $reg = Parse::Win32Registry->new($hive);
    my $root_key = $reg->get_root_key;
    my $key;

    # SOFTWARE\RealNetworks\RealPlayer\20.0\Preferences\DataCacheCheck
    # SOFTWARE\RealNetworks\RealPlayer\20.0\Preferences\InstallDate
    # SOFTWARE\RealNetworks\RealPlayer\20.0\Preferences\LastLoginTime
    # SOFTWARE\RealNetworks\RealPlayer\20.0\Preferences\LastOpenFileDir
    # SOFTWARE\RealNetworks\RealPlayer\20.0\Preferences\LastPlayerLaunchDate
    # SOFTWARE\RealNetworks\RealPlayer\20.0\Preferences\LastStartupVersion
    # SOFTWARE\RealNetworks\RealPlayer\20.0\Preferences\RunCount
    my @paths = ("DataCacheCheck", "InstallDate", "LastLoginTime", "LastOpenFileDir", "LastPlayerLaunchDate", "LastStartupVersion", "RunCount");

    # SOFTWARE\RealNetworks\RealPlayer\20.0\Preferences\MostRecentClips{number}
    my $key = $root_key->get_subkey("SOFTWARE\\RealNetworks\\RealPlayer\\20.0\\Preferences");
    if ($key) {
        my @sk = $key->get_list_of_subkeys();
        if (scalar(@sk) > 0) {
            foreach my $s (@sk) {
                if ($s->get_name =~ m/MostRecentClips([0-9]+)/) {
                    push(@paths, $s->get_name);
                }
            }
        }
    }

    foreach my $name (@paths) {
        if ($key = $root_key->get_subkey("SOFTWARE\\RealNetworks\\RealPlayer\\20.0\\Preferences\\".$name)) {
            ::rptMsg("[-] SOFTWARE\\RealNetworks\\RealPlayer\\20.0\\Preferences\\".$name);
            ::rptMsg("LastWrite Time ".::getDateFromEpoch($key->get_timestamp())."Z");

            my $data = $key->get_value("")->get_data(); # (Default)
            if ($data){
                if ($name eq "LastLoginTime" or $name eq "DataCacheCheck") {
                    ::rptMsg($name." (Default) : ".localtime($data));
                }
                else {
                    ::rptMsg($name." (Default) : ".$data);
                }
            }
        }
        else {
            ::rptMsg("[-] SOFTWARE\\RealNetworks\\RealPlayer\\20.0\\Preferences\\".$name." not found.");
        }
        ::rptMsg("");
    }
}