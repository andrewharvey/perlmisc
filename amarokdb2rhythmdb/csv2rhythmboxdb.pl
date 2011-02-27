#!/usr/bin/perl -w

# Info: Converts a CSV extract from an Amarok 1.4 PostgreSQL database into the
#       rhythmdb 1.6 XML format.
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

# = README =
# Notes I had to do some minor fixes to hte source CSV file manually,
# Remove some non ASCII characters with non-UTF encoding, and
# Remove a 0x01 character.

use strict;

use XML::Writer;
use Text::CSV;
use IO::File;
use URI::Escape;

#output.xml usually is found in ~/.local/share/rhythmbox/rhythmdb.xml
(print("Usage: $0 input.csv output.xml\n") && exit) unless ((defined $ARGV[0]) && (defined $ARGV[1]));

#global variables
my $xmlout = new IO::File(">$ARGV[1]");
my $xmlwriter = new XML::Writer(OUTPUT => $xmlout);

my $csvfile = $ARGV[0];
my $csv = Text::CSV->new ( { binary => 1, 
#                               sep_char => "\t",
#                               allow_loose_quotes => 1, # because psql will not bother to quote and escape quotes
                               empty_is_undef => 1 # make empty values undef
                                } )  # should set binary attribute.
                 or die "Cannot use CSV: ".Text::CSV->error_diag ();
                 
open my $csvfh, "<", $csvfile or die "$csvfile: $!";

$xmlwriter->xmlDecl("UTF-8");

#start the XML file
$xmlwriter->startTag("rhythmdb", "version" => "1.6");

$csv->column_names($csv->getline($csvfh));

#read through the input CSV file
while ( my $row_hash = $csv->getline_hr( $csvfh ) ) {
    $xmlwriter->startTag('entry', 'type' => 'song');
    foreach my $key (keys %{ $row_hash } ) {
        my $value = $row_hash->{$key};
        
        #print "$key: " . $value . "\n";
        $key =~ s/_/-/; # SQL didn't like - in field names, so we used _, but rhythmdb wants -
        
        if (defined $value) {
            if ($key eq 'location') {
                # amarok used ./home/... but rhythmdb uses file:///home/...
                # so replace leading . with file://
                $value = uri_escape_utf8($value);
                $value =~ s/%2F/\//g;
                
                $value =~ s/^\./file\:\/\//;
            }
            $xmlwriter->dataElement($key, $value);
        }
    }
    $xmlwriter->endTag('entry');
}
$csv->eof or $csv->error_diag();
close $csvfh;

#finish the XML file and exit
$xmlwriter->endTag("rhythmdb");
$xmlwriter->end();
$xmlout->close();
print "Successfully Completed.\n";
exit;
