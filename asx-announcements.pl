#!/usr/bin/perl -wT

# Info: When called will collect collect ASX announcements for the given company
#       code, and returns results in an RSS format.
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
# Date: 10 Sep 2010 
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

# Designed to be run as a CGI script, code for running from command line is
# commented out.

# When run from CGI the paramater should be code=XXX where XXX is the ASX code.

use strict;

# apt-get install libwww-perl libhtml-tree-perl libxml-rss-perl libtimedate-perl
use LWP::Simple;        #to fetch the HTML page
use HTML::TreeBuilder;  #to parse the HTML page
use XML::RSS;			#to generate the RSS file
use Date::Format;       #to format datetimes

use CGI;
my $q = new CGI();

#get code from CGI query and check it matches the expected format
my $asx_code = $q->param('code');
$asx_code = uc($asx_code);
if ($asx_code !~ /^[A-Z]{3}$/) { #should this always be 3 a-z chars?
    print $q->header(-status=>'400'),
          $q->start_html('400 Bad request'),
          $q->h2('You must supply a code paramater of exactly three A-Z characters.');
    exit 0;
}

#or we can just get it from the program arguments
#my $asx_code = $ARGV[0];

my $asx_domain = "http://www.asx.com.au";
my $page_url = "$asx_domain/asx/statistics/announcements.do?by=asxCode&asxCode=".$asx_code."&timeframe=Y&year=".time2str("%Y", time);

#get the HTML page from the ASX site
my $html = get($page_url);
if ($html eq '') {
    exit;
}

# Create the RSS object.
my $rss = XML::RSS->new( version => '2.0' );

my $feed_title = "ASX Announcements for ".$asx_code;

# Prep the RSS.
$rss->channel(
	title        	=> $feed_title,
	link         	=> $page_url,
	language     	=> 'en',
	lastBulidDate	=> time2str("%a, %d %b %Y %T GMT", time),
	);

$rss->image(
	title	=> $feed_title,
	url		=> "$asx_domain/images/asx_header_logo.jpg",
	link	=> $page_url
	);


#parse the HTML of the index page
my $element;
my $tree = HTML::TreeBuilder->new;
$tree->parse($html); $tree->eof;
$tree->elementify();

#find the table that lists all the data
my @table = $tree->look_down('_tag', 'table',
                             'class', 'contenttable');

my @rows = $table[0]->look_down('_tag','tr');

shift @rows; #we don't need the header of the table...
my $index = 1;
foreach my $row (@rows) {
    if (defined $row) {
        my ($date, $price_sen, $headline, $pages, $pdf, $txt) = $row->look_down('_tag', 'td');
        
        $headline = $headline->as_text();
        $headline =~ s/ *$//; #remove trailing whitespace

        $date = $date->as_text();
        $pages = $pages->as_text();
        
        my $pdf_link;
        #if no PDF link, try to use TXT link instead
        if (!defined $pdf->look_down('_tag', 'a')) {
            if (!defined $txt->look_down('_tag', 'a')) {
                $pdf_link = "";
            }else{
                $pdf_link = $asx_domain.$txt->look_down('_tag', 'a')->attr('href');
            }
        }else {
            $pdf_link = $asx_domain.$pdf->look_down('_tag', 'a')->attr('href');
        }

        if ((defined $price_sen->look_down('_tag', 'img')) && ($price_sen->look_down('_tag', 'img')->attr('alt') eq 'asterix')) {
            $price_sen = " - Price sensitive.";
        }else{
            $price_sen = "";
        }
        
        $rss->add_item( 
			title 		=> $headline,
			permaLink 	=> $pdf_link,
			enclosure	=> { url=>$pdf_link, type=>"application/pdf"},
			description 	=> "<![CDATA[$date$price_sen - $pages pages.]]>");
    }
}

print $q->header('application/rss+xml');
print $rss->as_string."\n";

#or we could just save it to file instead
#$rss->save("asx-$asx_code.xml");

exit;
