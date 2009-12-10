#!/usr/bin/perl

# Info: Program to pause Amarok 1.4 playback when the screenlocks and start
#       it again when the screen is unlocked (if it was playing when locked).
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
# Date: 10 Dec 2009
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

# Usage: ./
# You probably want to start this script either at startup or when amarok is started.
# This script will not start amarok if it is not started.

# Also, there are some python scripts for doing the same kind of thing at,
# http://nxsy.org/getting-amarok-to-pause-when-the-screen-locks-using-python-of-course
# And a perl script (that I discovered after writing this one) at,
# http://cpansearch.perl.org/src/IVANWILLS/Event-ScreenSaver-0.0.3/bin/player-pause

use warnings;
use strict;

use Net::DBus;
use Net::DBus::Reactor;

my $bus = Net::DBus->session();
my $service = $bus->get_service("org.gnome.ScreenSaver");
my $object = $service->get_object("/org/gnome/ScreenSaver");

my $need_replay = 0; #flag to remember state of audio on screenlock (for unlock)

#print debug messages (just comment out the print line to forget about this)
sub DEBUG($) {
    my ($line) = @_;
    print STDERR "DEBUG: $line\n";
}

sub signal_handler {
    my $dbus_message = shift;
    #1     = locking (true)
    #undef = unlocking (false)
    
    my $isPlaying = `dcop amarok player isPlaying`;
    chomp $isPlaying;
    if ($isPlaying eq "true") {
        if ($dbus_message) {
            #screen has just been locked and the audio was playing
    	    `dcop amarok player pause`; #pause
    	    $need_replay = 1; #set flag to start again on unlock
    	    DEBUG("screen locked + playback active => playback paused");
        }else{
            #screen has just been unlocked
            #but the music was playing when locked
            DEBUG("screen unlocked but playback already active");
        }
    }elsif ($isPlaying eq "false") {
      if ($dbus_message) {
            #screen has just been locked and the audio was NOT playing
    	    $need_replay = 0; #unset flag so don't start audio again on unlock
       	    DEBUG("screen locked but playback was not active => will not restart playback on unlock");
        }else{
            #screen has just been unlocked
            if ($need_replay) {
                #audio was playing when locked
                #so we need to start it again
                `dcop amarok player play`; #play
                DEBUG("screen unlocked => restarting playback");
            }else{
                DEBUG("screen unlocked but don't need to restart playback");
            }
        }
	
    }else{ #typically will be "ERROR: Couldn't attach to DCOP server!"
	    print "Cannot talk to amarok via dcop. (Amarok is probably not active)\n";
	    print "Response: $isPlaying\n";
    }
}

$object->connect_to_signal("ActiveChanged", \&signal_handler);

my $reactor = Net::DBus::Reactor->main();

#start the loop that will call signal_handler when a signal is detected
$reactor->run();
