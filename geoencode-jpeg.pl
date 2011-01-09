#!/usr/bin/perl -w

# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

use Image::ExifTool;
use Image::ExifTool::Location;

if (@ARGV < 5) {
    die ("Usage: $0 source_image dest_image lat lon ele");
}

$src = $ARGV[0];
$dst = $ARGV[1];
$lat = $ARGV[2];
$lon = $ARGV[3];
$ele = $ARGV[4];

my $exif = Image::ExifTool->new();

# Extract info from existing image
$exif->ExtractInfo($src);

# Set location
# requires latitude and longitude values in decimal degrees.
$exif->SetLocation($lat, $lon);

# Set elevation
$exif->SetElevation($ele);

# Write new image
$exif->WriteInfo($src, $dst);
