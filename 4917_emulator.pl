#!/usr/bin/perl -w

# 4917 Microprocessor (theoretical) Emulator
# The 4917 Microprocessor was used in the
# COMP1917 08s1 course (http://www.cse.unsw.edu.au/~cs1917/08s1/).
# 
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
# Date: 26 Nov 2009

# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring 
# rights to this work. 
# http://creativecommons.org/publicdomain/zero/1.0/

use strict;

sub startUp();
sub printout();
sub fetchExec();
sub execute();

my $IP; #instruction pointer
my $IS; #instruction store
my $IS1; #byte 2 of the instruction store
my $R0; #register 0
my $R1; #register 1
my @instructions = (); #array of the program
my $inf = 1000; #if we have done the fetch-execute cycle 1000 times, just give up
my $infloop_counter = 0;
my $output = ""; #hold back the print's so we can clean it up
my $debug = ""; #debugging/tracing info

my $HALT = 0; #halt is instruction 0

&startUp();

while () {
    &fetchExec();
}

sub startUp() {
    #initialise IP and regiserters
    $IP = 0;
    $R0 = 0;
    $R1 = 0;
    @instructions = ();

    #read the input into memory (an array)
    while (<>) {
        push @instructions, split;
    }

    for (my $i = @instructions; $i < 16; $i++) {
        $instructions[$i] = 0; #set any memory locations not defined as 0.
    }

    if (@instructions > 16) {
        print "There are only 16 memory locations. You input will be truncated.\n";
        #FIXME there must be a better way...
        for (my $i = $#instructions; $i >= 16; $i++) {
            undef $instructions[$i];
        }
    }

#    print "@instructions\n";
}

#Fetch-Execute Cycle
sub fetchExec() {
    if ($IP > $#instructions) {
        print "IP points to undefined address. Stopping\n";
        printout();
        exit;
    }
    $IS = $instructions[$IP];
#    if ($IS == $HALT) {
#        exit;
#    }
    $IP++;
    if ($IP > $#instructions) {
        print "Do you have a 2-byte instruction in the last memory location? Stopping.\n";
        printout();
        exit;
    }
    if ($IS >= 8) { #two byte instructions
        $IS1 = $instructions[$IP];
        $IP++;
    }
    execute();
    if ($infloop_counter >= $inf) {
        print "Does this program ever end?\n";
        printout();
        exit;
    }
    $infloop_counter++;
}

sub execute() {
    if ($IS == 0) { #halt
        $debug .= "halt";
        printout();
        exit;
    }elsif ($IS == 1) { #add
        $R0 = $R0 + $R1;
        $debug .= "add r0 (r0 = $R0)";
    }elsif ($IS == 2) { #sub
        $R0 = $R0 - $R1;
        $debug .= "sub r0 (r0 = $R0)";
    }elsif ($IS == 3) { #inc R0
        $R0 = $R0 + 1;
        $debug .= "inc r0 (r0 = $R0)";
    }elsif ($IS == 4) { #inc R1
        $R1 = $R1 + 1;
        $debug .= "inc r1 (r1 = $R1)";
    }elsif ($IS == 5) { #dec R0
        $R0 = $R0 - 1;
        $debug .= "dec r0 (r0 = $R0)";
    }elsif ($IS == 6) { #dec R1
        $R1 = $R1 - 1;
        $debug .= "dec r1 (r1 = $R1)";
    }elsif ($IS == 7) { #Ring Bell
        $output .= " BELL";
        $debug .= "bell";
    }elsif ($IS == 8) { #Print <data>
        $output .= " $IS1";
        $debug .= "print $IS1";
    }elsif ($IS == 9) { #ld <data> into r0
        $R0 = $instructions[$IS1];
        $debug .= "ld r0, addr $IS1 ($instructions[$IS1])";
    }elsif ($IS == 10) { #ld <data> into r1
        $R1 = $instructions[$IS1];
        $debug .= "ld r1, addr $IS1 ($instructions[$IS1])";
    }elsif ($IS == 11) { #store r0 into addr <data>
        $instructions[$IS1] = $R0;
        $debug .= "st $IS1, r0 ($R0) ($R0 into addr $IS1) memory: @instructions";
    }elsif ($IS == 12) { #store r1 into addr <data>
        $instructions[$IS1] = $R1;
        $debug .= "st $IS1, r1 ($R1) ($R1 into addr $IS1) memory: @instructions";
    }elsif ($IS == 13) { #jmp to addr <data>
        $IP = $IS1;
        $debug .= "jmp $IS1";
    }elsif ($IS == 14) { #jmp to addr <data> if R0 == 0
        $IP = $IS1 if ($R0 == 0);
        $debug .= "jmp $IS1, if $R0 == 0";
    }elsif ($IS == 15) { #jmp to addr <data> if R0 != 0
        $IP = $IS1 if ($R0 != 0);
        $debug .= "jmp $IS1, if $R0 != 0";
    }
    
    $debug .= "\n";
}

sub printout() {
#    print "Trace:\n";
#    print "$debug";

    $output .= "\n";
    #pretty print
    $output =~ s/^\s*//; #trim leading whitespace
    $output =~ s/\s*$//; #trim tailing whitespace
    print "$output";
}
