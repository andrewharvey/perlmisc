#!/usr/bin/perl -w

# Info: Queries a UPnP supported router for total bytes sent and recieved and
#       prints this information to stdout in a format parseable by Compa
#       (http://code.google.com/p/compa/) for display in the Gnome panel.
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
# Date: 26 Jul 2010
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

# On Ubuntu you need to install the package libnet-upnp-perl
# For other systems look for Net::UPnP in CPAN

use Net::UPnP::ControlPoint;
use Net::UPnP::GW::Gateway;

sub toReadable($) {
    my ($i) = @_;
    if ($i < 1024) {
        return "$i bytes";
    }elsif ($i < 1024**2) {
        return sprintf("%.2f KB", $i/1024);
    }elsif ($i < 1024**3) {
        return sprintf("%.2f MB", $i/(1024**2));
    }elsif ($i < 1024**4) {
        return sprintf("%.2f GB", $i/(1024**3));
    }else {
        return sprintf("%.2f TB", $i/(1024**4));
    }
}

my $obj = Net::UPnP::ControlPoint->new();

@dev_list = $obj->search(st =>'urn:schemas-upnp-org:device:InternetGatewayDevice:1', mx => 1); #For me an mx of 1 still made this line take about 2 seconds, if I made the mx larger it just took longer.

$dev = $dev_list[0];

if ((!defined $dev)
    || ($dev->getdevicetype() ne 'urn:schemas-upnp-org:device:InternetGatewayDevice:1')
    || !($dev->getservicebyname('urn:schemas-upnp-org:service:WANIPConnection:1'))
    || ($dev->getfriendlyname() ne "Your Router's Friendly Name") ) { #to prevent weird error messages appearing in your panel if you change routers or simply aren't connected.
    #print "Friendly Name: " . $dev->getfriendlyname(); #TODO: use this to discover what to use in the line above!
    print "<span>n/a</span>\n";
}else{
    my $gwdev = Net::UPnP::GW::Gateway->new();
    $gwdev->setdevice($dev);
    #print "<span>" . $gwdev->getexternalipaddress() . "</span>\n";
    print "<span size=\"x-small\" foreground=\"#5AA7FF\">↓" . toReadable($gwdev->gettotalbytesrecieved()) . "</span>\n";
    print "<span size=\"x-small\" foreground=\"#FFF75B\">↑" . toReadable($gwdev->gettotalbytessent()) . "</span>\n";
}
