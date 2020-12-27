package winscp2;
use strict;
use Encode;

my %config = (hive          => "NTUSER\.DAT",
              hasShortDescr => 1,
              hasDescr      => 0,
              hasRefs       => 0,
              osmask        => 22,
              version       => 20201206);

sub getConfig{return %config}
sub getShortDescr {
    return "winscp2"
}
sub getDescr{}
sub getRefs {}
sub getHive {return $config{hive};}
sub getVersion {return $config{version};}

# https://metacpan.org/pod/release/GAAS/URI-1.52/URI/Escape.pm
sub uri_unescape
{
    # Note from RFC1630:  "Sequences which start with a percent sign
    # but are not followed by two hexadecimal characters are reserved
    # for future extension"
    my $str = shift;
    if (@_ && wantarray) {
        # not executed for the common case of a single argument
        my @str = ($str, @_);  # need to copy
        foreach (@str) {
            s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg;
        }
        return @str;
    }
    $str =~ s/%([0-9A-Fa-f]{2})/chr(hex($1))/eg if defined $str;
    $str;
}

sub pluginmain {
    my $class = shift;
    my $hive = shift;
    ::logMsg("[*] Launching winscp v.".getVersion());
    my $reg = Parse::Win32Registry->new($hive);
    my $root_key = $reg->get_root_key;
    my $key;
    my @paths = ("SOFTWARE\\Martin Prikryl\\WinSCP 2\\Configuration\\Interface\\Explorer",
        "SOFTWARE\\Martin Prikryl\\WinSCP 2\\Configuration\\Usage\\Values");

    my @nameList = ("LastLocalTargetDirectory", "FirstUse", "FirstVersion", "Installed", "LastReport", "OpenedSessionsFailedLastDate", "WindowsProductName");

    foreach my $key_path (@paths) {
        if ($key = $root_key->get_subkey($key_path)) {
            ::rptMsg("[-] ".$key_path);
            ::rptMsg("LastWrite Time ".::getDateFromEpoch($key->get_timestamp())."Z");

            foreach my $name (@nameList) {
                my $data = $key->get_value($name);
                if ($data){
                    ::rptMsg($name." : ".$data->get_data());
                }
            }
        }
        else {
            ::rptMsg("[-] ".$key_path." not found.");
        }
        ::rptMsg("");
    }

    foreach my $name (("LocalPanel", "RemotePanel")) {
        if ($key = $root_key->get_subkey("SOFTWARE\\Martin Prikryl\\WinSCP 2\\Configuration\\Interface\\Commander\\".$name)) {
            ::rptMsg("[-] "."SOFTWARE\\Martin Prikryl\\WinSCP 2\\Configuration\\Interface\\Commander\\".$name);
            ::rptMsg("LastWrite Time ".::getDateFromEpoch($key->get_timestamp())."Z");

            my $data = $key->get_value("LastPath")->get_data();
            ::rptMsg("LastPath : ".$data);
            ::rptMsg("LastPath (URI decode) : ".Encode::decode("utf8", uri_unescape($data)));
        }
        else {
            ::rptMsg("[-] SOFTWARE\\Martin Prikryl\\WinSCP 2\\Configuration\\Interface\\Commander\\".$name." not found.");
        }
        ::rptMsg("");
    }
}