#!/usr/bin/perl -w

# Tester for 4917_emulator.pl
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
# Date: 26 Nov 2009

# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring 
# rights to this work. 
# http://creativecommons.org/publicdomain/zero/1.0/

use strict;

my $test_no = 0; #test number

#testing code
sub run($$) {
    my ($in, $eout) = @_;
    # $in = input data
    # $eout = expected output

    $test_no++;
    print "Running test $test_no...\n";
    my $out = `echo '$in' | ./4917_emulator.pl`;
    if ($out ne "$eout") {
        print "\nTest $test_no FAIL.\n>>Input:\n>>$in\\\n>>Output:\n>>$out\\\n>>Expected:\n>>$eout\\\n";
    }
}

#test cases
#run("", ""); #no input no output
run("0", ""); #halt
run("1 1 1 1 2 3 2 4 5 6 0", ""); #
run("1 2 3 4 5 6 7 0", "BELL"); #
run("8 0 0", "0"); #print
run("8 2 0", "2"); #
run("8 1 8 2 0", "1 2"); #
#    0 1 2 3 4 5  6  7  8  9 10 11 12 
run("3 3 4 4 4 11 10 12 12 8 0 8 0 0", "2 3"); #inc and st
run("13 4 8 1 0", ""); #jmp over a print
run("13 4 5 6 9 0 10 1 2 11 12 8 0 0", "9"); #R0 = 13, R1 = 4; sub therefore R0 = 9
#run("", ""); #
