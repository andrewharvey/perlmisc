#!/usr/bin/perl -w

# Info: When run this script will randomly choose a set of wallpapers from the
#       certain directories and then add them as compiz wallpapers for different
#       workspace, so for them to appear in the background you will need to 
#       enable the Compiz Wallpaper plugin.
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
# Date: 25 Feb 2010 
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

# Usage: ./change_compiz_wallpapers.pl
# PS. You can use cron to run this at regular intervals...

use strict;
use List::Util 'shuffle';

my @dirs = ("/usr/share/backgrounds/", "$ENV{HOME}/Pictures/"); #directories to search for images
my $NUM_DESKTOPS = 9;
my @bgs = ();
my @files = (); # a list of all the image files in all the dirs.

#for each directory in the given list of directories...
for my $dir (@dirs) {
   chdir $dir;
   #add all the files matching this filetype to a global list of files
   push @files, map("$dir$_",glob('*.{jpg,jpeg,png}'));
}

#print join("\n", @files)."\n"; #print all the files avaliable for debugging

#randomly pick an image for each desktop
#(just shuffle the list and pick the first few, this avoids duplicates)
@files = shuffle(@files);

die "Error: No sutiable files found.\n" if (@files == 0);

if (@files < $NUM_DESKTOPS) {
   print "Warning: Not enough files to avoid duplicates.\n";
   #...so we'll just pick some at random...
   for my $i (0..($NUM_DESKTOPS-1)) {
      push @bgs, $files[int(rand(@files))];
   }
}else{
   for my $i (0..($NUM_DESKTOPS-1)) {
      push @bgs, $files[$i];
   }
}

#need to escape , and \ and ] with a \
#hope this is enough, I should really use a gconf perl module actually...
map(s/([,\]\\])/\\$1/g,@bgs);

my $string = 'gconftool-2 --set --type list --list-type string /apps/compiz/plugins/wallpaper/screen0/options/bg_image "['.join(',', @bgs).']"';
#eg. `gconftool-2 --set --type list --list-type string /apps/compiz/plugins/wallpaper/screen0/options/test "[a,b,c]"`

#execute
`$string`;

#print "$string\n"; #to debug

exit;
