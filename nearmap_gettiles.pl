#!/usr/bin/perl -w

#This script does mass downloading of map tiles served in an openstreetmap style.
#You'll need to change the source to change the paramaters of the download,
#so its not meant to be an off the shelf solution.
#Dependencies: You need wget installed.
#              Only tested on linux.

#This code is in the public domain.

#At the time of writting the imagery this code is designed to download is 
#governed by the licence terms at 
#http://www.nearmap.com/legal/community-licence.aspx

#They have also stated that they are okay with this kind of mass downloading.
#Q. Can I download photo tiles for my own use?
#A. Yes. You can use all tiles for personal use under the terms of our 
#Community (Personal) Licence.
#http://www.nearmap.com/help/faq.aspx#download-for-own-use

#Q. Can I download lots of tiles?
#A. Yes; if you abide by our licence agreements. However if you download a large
#amount of data from our servers, we may have to limit your speeds in order to 
#give everyone fair access to the site. Please be considerate of everyone else 
#when you’re thinking of downloading a large amount of data. 
#http://www.nearmap.com/help/faq.aspx#download-lots-of-tiles

sub getTileYNumber;
sub getTileXNumber;

my $cookie_num = time;

#get the session cookie (not required, but they ask for client applications to do this)
`wget --quiet --save-cookies cookiefile$cookie_num -O /dev/null "http://www.nearmap.com/maps/nmq=getsession"`;

my $nml="Vert"; #Dem, Vert, S, W, N, E,
my @bbox = (150, -35, 151.6, -33);
my @zrange = (1, 17);
my $wgetcmd = "wget --quiet --load-cookies cookiefile$cookie_num --tries=3 --timeout=30 --waitretry=30";

my $base = "nearmap/$nml/date";

my $middleX = getTileXNumber(($bbox[0]+$bbox[2])/2,$zrange[1]);
my $middleY = getTileYNumber(($bbox[1]+$bbox[3])/2,$zrange[1]);
my $middleZ = $zrange[1];

`mkdir -p "$base"`;
`$wgetcmd -O "$base/info.xml" "http://www.nearmap.com/maps/nml=$nml&x=$middleX&y=$middleY&z="$middleZ&nmq=info&nmf=xml`;

foreach my $z ($zrange[0]..$zrange[1]) {
  print "$z: ";
  foreach my $x (getTileXNumber($bbox[0],$z)..getTileXNumber($bbox[2],$z)) {
    print ".";
    foreach my $y (getTileYNumber($bbox[3],$z)..getTileYNumber($bbox[1],$z)) {
      `mkdir -p "$base/$z/$x/"`; #wget needs the directories to exist
      if (!( -e "$base/$z/$x/$y.jpg" )) { #if the file is already there (helps if we cancel, and then want to pick up where we left off)
        `$wgetcmd -O "$base/$z/$x/$y.jpg" "http://www.nearmap.com/maps/nml=$nml&x=$x&y=$y&z=$z"`;
        if (-z "$base/$z/$x/$y.jpg") {
          `rm "$base/$z/$x/$y.jpg"`; #the file is empty, so no point keeping it
        }
      } #else the file is already there
    }
  }
  print "\n";
}

`rm cookiefile$cookie_num`;

#to convert from WGS to coordinates used for the tiles...
use Math::Trig;
sub getTileYNumber {
  my ($lat,$zoom) = @_;
  my $ytile = int( (1 - log(tan($lat*pi/180) + sec($lat*pi/180))/pi)/2 *2**$zoom ) ;
  return $ytile;
}
sub getTileXNumber {
  my ($lon,$zoom) = @_;
  my $xtile = int( ($lon+180)/360 *2**$zoom ) ;
  return $xtile;
}
