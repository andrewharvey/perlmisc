#!/usr/bin/perl -w

# Info: Uses DateTime::Event::Sunrise to calculate sunrise and sunset times,
#       initially for use in a http://danvk.org/dygraphs/ graph.
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
# Date: 20 Feb 2010 
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

# Usage: ./

#TODO:

#add other lines for different altitude values (even better allow the user to 
#select which ones to show. there is a dygraph example of this)

#get graph to put sunrise on the top

#turn this into a CGI script, so that a user can choose any location or timezone

#ideally one could implement DateTime::Event::Sunrise in JavaScript so that the 
#user can hover over different locations on a map an in realtime see how the 
#graph changes.
#one could also then see how changing the year affects things (if at all)


use strict;

use DateTime;
use DateTime::Set;
use DateTime::Span;
use DateTime::Duration;
use DateTime::Event::Sunrise;

my $CITY = 'Sydney';
my $TZ = 'Australia/Sydney';
my $YEAR = 2010;
my $LATLONG = '-33.859972,151.211111';


my $title1 = "$CITY ($TZ), $YEAR";
my $title2 = "($LATLONG)";

my ($lat, $long) = split /,/, $LATLONG;


=altitude
There are a number of sun altitudes to chose from. The default is -0.833 because this is what most countries use. Feel free to specify it if you need to. Here is the list of values to specify altitude (Altitude) with:

* 0 degrees
      Center of Sun's disk touches a mathematical horizon
* -0.25 degrees
      Sun's upper limb touches a mathematical horizon
* -0.583 degrees
      Center of Sun's disk touches the horizon; atmospheric refraction accounted for
* -0.833 degrees
      Sun's supper limb touches the horizon; atmospheric refraction accounted for
* -6 degrees
      Civil twilight (one can no longer read outside without artificial illumination)
* -12 degrees
      Nautical twilight (navigation using a sea horizon no longer possible)
* -15 degrees
      Amateur astronomical twilight (the sky is dark enough for most astronomical observations)
* -18 degrees
      Astronomical twilight (the sky is completely dark)
=cut

my $day1 = DateTime->new( 
    year   => $YEAR,
    month  => 1,
    day    => 1,
);
              
my $day2 = DateTime->new( 
    year   => $YEAR,
    month  => 12,
    day    => 31,
);

#make a Span object for the whole year                   
my $year_span = DateTime::Span->from_datetimes( start =>$day1, end=>$day2 );

my $days = DateTime::Set->from_recurrence(
    recurrence => sub {
        return $_[0] if $_[0]->is_infinite;
        return $_[0]->truncate( to => 'day' )->add( days => 1 )
    },
    span => $year_span,
);

#Civil twilight (one can no longer read outside without artificial illumination)
my $sunrise_span_civil = DateTime::Event::Sunrise ->new (
    longitude =>"$long",
    latitude =>"$lat",
    altitude => -6,
    iteration => '1'
);

#default
my $sunrise_span = DateTime::Event::Sunrise ->new (
    longitude =>"$long",
    latitude =>"$lat",
    altitude => -0.833,
    iteration => '1'
);


#write CSV file for graphing
open CSV, ">data.csv" or die "Problem writing to data.csv\n";
print CSV "date,Sunrise,Sunset,Sunrise (civil twilight),Sunset (civil twilight)\n";

my $it = $days->iterator;
while ( my $dt = $it->next) {
    last if !defined $dt;
    my $ssa = $sunrise_span->sunrise_datetime($dt);
    my $ssb = $sunrise_span->sunset_datetime($dt);

    my $ssa_civil = $sunrise_span_civil->sunrise_datetime($dt);
    my $ssb_civil = $sunrise_span_civil->sunset_datetime($dt);

    $ssa->set_time_zone( $TZ );
    $ssb->set_time_zone( $TZ );
    $ssa_civil->set_time_zone( $TZ );
    $ssb_civil->set_time_zone( $TZ );
    
    print CSV $dt->ymd.",";
    #dygraph wants decimal numbers for y values so we give it that, then
    #hack the dygraph js to show back in HH:MM
    #print CSV $sss->hms.",";
    #print CSV $sse->hms."\n";
    
    print CSV $ssa->hour + ($ssa->minute / 60);
    print CSV ",";
    print CSV $ssb->hour + ($ssb->minute / 60);
    print CSV ",";
    
    print CSV $ssa_civil->hour + ($ssa_civil->minute / 60);
    print CSV ",";
    print CSV $ssb_civil->hour + ($ssb_civil->minute / 60);
    print CSV "\n";
}
