#!/usr/bin/perl -w -T

# Info: CGI script to show colour Australian states different colours.
#       You need an svg template file like the one accompanying this with the
#       placeholder strings in it.
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
# Date: 18 Feb 2010 
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

# Usage: CGI SCRIPT
# example: http://host/graph_aus_states.pl?nt_fill=00aa22&nt_fill_opacity=0.5&act_fill=dd0000&stroke=1.3

use strict;
use CGI qw/:standard/;
use CGI::Carp qw(fatalsToBrowser warningsToBrowser);

warningsToBrowser(1); #perl warnings are sent to the browser in the HTML. (use 0 for production environment)

my $cgi = new CGI;

my @states = qw/nt qld nsw act tas vic sa wa/;

my %fill;
my %opacity;

#get the CGI parameters
for my $state (@states) {
    $fill{$state} = ($cgi->param("${state}_fill") || 'ffffff');
    $opacity{$state} = ($cgi->param("${state}_fill_opacity") || '1');
    $opacity{$state} = $cgi->param("${state}_fill_opacity") if ($cgi->param("${state}_fill_opacity") eq '0'); #in case 0 (rather than just undef)
}

#can't do, $v = ($cgi->param('q') || 1), because both 0 and undef result in a value 1 rather than just undef
my $stroke_width;
if (!defined $cgi->param("stroke")) {
    $stroke_width = '1';
}else{
    $stroke_width = $cgi->param("stroke");
}

#error check the CGI parameters
if ($stroke_width !~ /^\d+(\.\d+)?$/) {
    print $cgi->header(-status=> '400 Bad request', -type=>'text/plain');
    print "Fill opacity must be numeric.\nGiven:stroke=$stroke_width\n";
    exit;
}

foreach (keys %opacity) {
    if ($opacity{$_} !~ /^\d+(\.\d+)?$/) {
        print $cgi->header(-status=> '400 Bad request', -type=>'text/plain');
        print "Fill opacity must be numeric.\nGiven:$_=$opacity{$_}\n";
        exit;
    }
}

foreach (keys %fill) {
    if ($fill{$_} !~ /^[0-9a-fA-F]{6}$/) {
        print $cgi->header(-status=> '400 Bad request', -type=>'text/plain');
        print "Fill must be hexadecimal number of 6 digits (eg ffaacc).\nGiven:$_=$fill{$_}\n";
        exit;
    }
}

#open the template file
open SVG, "australian_states_graphic_template.svg";

print $cgi->header(-type=>'image/svg+xml');

#replace the placeholder strings with CGI parameter values
while (<SVG>) {
    foreach my $k (keys %fill) {
        $_ =~ s/`${k}_fill`/#$fill{$k}/;
    }
    
    foreach my $k (keys %opacity) {
        $_ =~ s/`${k}_fill_opacity`/$opacity{$k}/;
    }
    $_ =~ s/`template_stroke_width`/$stroke_width/;
    print $_;
}

close SVG;

exit;
