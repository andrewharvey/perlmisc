#!/usr/bin/perl -w

# Info: Takes image files as arguments and runs the DectectFaces program, then
#       uses ImageMagick to crop these rectangles out as new files.
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

use strict;
use Image::Magick;
use File::Basename;

foreach $a (@ARGV) {
    #get rectangle coordinates of faces
    `./DetectFaces $a`;

    ### crop out these rectangles, and save each to a new file

    #open the coordinates file and read it in
    open COORDS, "<$a.txt";

    my $i = 0;
    while (my $line = <COORDS>) {
        #must read it in every time because it gets overwriten by Crop
        my($image, $x);
        $image = Image::Magick->new;
        
        $x = $image->Read("$a");
        warn "$x" if "$x";
        
        chomp $line;
        print "$line\n";
        
        $i++;

        my ($x1, $y1, $x2, $y2) = split /,/, $line;
        print (($x2-$x1)."x".($y2-$y1)."+$x1+$y1\n");
        $x = $image->Crop(geometry=>($x2-$x1)."x".($y2-$y1)."+$x1+$y1");
        warn "$x" if "$x";

        my ($name,$path,$suffix) = fileparse($a,qr/.[^.]*$/);
        print "name:$name path:$path suffix:$suffix\n";

        $x = $image->Write("$path$name.$i$suffix");
        warn "$x" if "$x";

    }
}
print "\n";

exit;
