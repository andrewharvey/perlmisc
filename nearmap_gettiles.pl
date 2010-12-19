#!/usr/bin/perl -w

# Info: NearMap.com mass tile downloader
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

#This script does mass downloading of map tiles served in an openstreetmap style.

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

#get params from args
if (@ARGV < 7) {
  print "Usage: ${0} nml left bottom right top minzoom maxzoom [date]\n";
  print "       nml = {Dem,Vert,S,W,N,E}\n";
  print "       date in form YYYYMMDD or blank for latest\n";
  exit;
}

#NearMap Layer
my $nml = shift @ARGV;
my $left = shift @ARGV;
my $bottom = shift @ARGV;
my $right = shift @ARGV;
my $top = shift @ARGV;

my $minzoom = shift @ARGV;
my $maxzoom = shift @ARGV;

my @bbox = ($left, $bottom, $right, $top);
my @zrange = ($minzoom, $maxzoom);

my $date = shift @ARGV;

#set up LWP, with connection caching and a cookie jar
use LWP::UserAgent;
my $ua = LWP::UserAgent->new;
$ua->agent("TileDownloader ");

use LWP::ConnCache;
my $cache = $ua->conn_cache(LWP::ConnCache->new());
$ua->conn_cache->total_capacity(15);

use HTTP::Cookies;
$ua->cookie_jar(HTTP::Cookies->new);

sub getTileYNumber;
sub getTileXNumber;

#get the session cookie
my $cookie_req = HTTP::Request->new(GET => 'http://www.nearmap.com/maps/nmq=getsession');
my $cookie_res = $ua->request($cookie_req);

if (!$cookie_res->is_success) {
  die "Unable te getsession cookie, ".$cookie_res->status_line."\n";
}

my $base = "nearmap/$nml/";

if (!defined $date) {
  $base .= "latest";
  $date = "";
}else{
  $base .= $date;
  $date = "nmd=$date&";
}

my $middleX = getTileXNumber(($bbox[0]+$bbox[2])/2,$zrange[1]);
my $middleY = getTileYNumber(($bbox[1]+$bbox[3])/2,$zrange[1]);
my $middleZ = $zrange[1];

`mkdir -p "$base"`;

my ($requests_current, $requests_limit);
my ($kb_current, $kb_limit);

print "Getting z ".$zrange[0]." to ".$zrange[1]."\n";
my $requests = 0;
foreach my $z ($zrange[0]..$zrange[1]) {
  my $xmin = getTileXNumber($bbox[0],$z);
  my $xmax = getTileXNumber($bbox[2],$z);
  my $ymin = getTileYNumber($bbox[3],$z);
  my $ymax = getTileYNumber($bbox[1],$z);
  print "   Getting x ".$xmin." to ".$xmax."\n";
  print "   Getting y ".$ymin." to ".$ymax."\n";
  my $numxs = abs($xmax - $xmin)+1;
  my $numys = abs($ymin - $ymax)+1;

  print "$z:";
  foreach my $x ($xmin..$xmax) { #east to west
    printf ("%.1f", (abs($xmin - $x)*100/$numxs));
    print "\% ";
    foreach my $y ($ymin..$ymax) {
      `mkdir -p "$base/$z/$x/"`; #wget needs the directories to exist
      if (!( -e "$base/$z/$x/$y.jpg" )) { #if the file is already there (helps if we cancel, and then want to pick up where we left off)
        my $res = $ua->request(HTTP::Request->new(GET => "http://www.nearmap.com/maps/nml=$nml&${date}x=$x&y=$y&z=$z"));
        if ($res->is_success) {
          open TILE, ">$base/$z/$x/$y.jpg";
          print TILE $res->content;
          close TILE;
        }
        my $req_per_sec = $res->header("X-HyperWeb-RequestsPerSecond");
        ($requests_current, $requests_limit) = split /\//, $req_per_sec;
        if ($requests_current * 2 > $requests_limit) {
          print STDERR "too many requests per sec, ", $req_per_sec, "\n";
          sleep 10;
        }
        my $kb_per_sec = $res->header("X-HyperWeb-KbPerSecond");
        ($kb_current, $kb_limit) = split /\//, $kb_per_sec;
        if ($kb_current * 2 > $kb_limit) {
          print STDERR "too many kb per sec, ", $kb_per_sec, "\n";
          sleep 10;
        }
        print "req $req_per_sec, kb $kb_per_sec\n";
        $requests++;
        if ($requests > 150) {
          print STDERR "sleeping...\n";
          sleep 1;
          $requests = 0;
        }

        #if (-z "$base/$z/$x/$y.jpg") {
          #`rm "$base/$z/$x/$y.jpg"`; #the file is empty, so no point keeping it
          #or we can keep it here so we don't ask again next time
        #}
      } #else the file is already there
    }
  }
  print "\n";
}

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
