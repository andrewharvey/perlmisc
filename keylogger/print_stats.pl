#!/usr/bin/perl -w

# Info: Display's stats from a logfile from keylogger.pl
#       The keycode to key mapping is for my keyboard, most likelly you will
#       need to change the parts that differ between qwerty and dvorak layouts.
# Author: Andrew Harvey (http://andrewharvey4.wordpress.com/)
#
# To the extent possible under law, the person who associated CC0
# with this work has waived all copyright and related or neighboring
# rights to this work.
# http://creativecommons.org/publicdomain/zero/1.0/

use strict;

#standard keyboard keycode to key label mapping
my %name = (
            29=>'L Ctrl',
            125=>'L Super',
            56=>'L Alt',
            57=>'Space',
            100=>'R Alt',
            126=>'R Super',
            127=>'Menu',
            97=>'R Ctrl',
            105=>'Left',
            108=>'Down',
            106=>'Right',
            103=>'Up',
            82=>'NumPad 0',
            83=>'NumPad .',
            96=>'NumPad Enter',
            78=>'NumPad +',
            74=>'NumPad -',
            55=>'NumPad *',
            98=>'NumPad /',
            69=>'NumLock',
            79=>'NumPad 1',
            80=>'NumPad 2',
            81=>'NumPad 3',
            75=>'NumPad 4',
            76=>'NumPad 5',
            77=>'NumPad 6',
            71=>'NumPad 7',
            72=>'NumPad 8',
            73=>'NumPad 9',
            111=>'Delete',
            107=>'End',
            109=>'Page Down',
            110=>'Insert',
            102=>'Home',
            104=>'Page Up',
            99=>'PrintScrn/SysRq',
            70=>'Scroll Lock',
            119=>'Pause/Break',
            42=>'L Shift',
            58=>'CapsLock',
            #1=>'CapsLock On/Off',
            15=>'Tab',
            54=>'R Shift',
            28=>'Enter',
            43=>"\\",
            14=>'Backspace',
            1=>'Esc',
            41=>'`',
            2=>'1',
            3=>'2',
            4=>'3',
            5=>'4',
            6=>'5',
            7=>'6',
            8=>'7',
            9=>'8',
            10=>'9',
            0=>'11',

            59=>'F1',
            60=>'F2',
            61=>'F3',
            62=>'F4',
            63=>'F5',
            64=>'F6',
            65=>'F7',
            66=>'F8',
            67=>'F9',
            68=>'F10',
            69=>'F11',
            70=>'F12',

            #dvorak specific (compared to qwerty):
            44=>';',
            45=>'q',
            46=>'j',
            47=>'k',
            48=>'x',
            49=>'b',
            50=>'m',
            51=>'w',
            52=>'v',
            53=>'z',
            
            30=>'a',
            31=>'o',
            32=>'e',
            33=>'u',
            34=>'i',
            35=>'d',
            36=>'h',
            37=>'t',
            38=>'n',
            39=>'s',
            40=>'-',

            16=>"'",
            17=>',',
            18=>'.',
            19=>'p',
            20=>'y',
            21=>'f',
            22=>'g',
            23=>'c',
            24=>'r',
            25=>'l',
            26=>'/',
            27=>'=',

            12=>'[',
            13=>']',
           );

#make sure we have a logfile argument
if (@ARGV < 1) {
    print "Usage $0 logfile\n";
    exit 1;
}

open LOGFILE, $ARGV[0];

my %keys;
my $total; #total keys logged

while (<LOGFILE>) {
    chomp;
    my ($_, $keycode) = split /,/;
    $keys{$keycode}++;
    $total++;
}

#and foreach key (sorted by value)
foreach my $key (sort { $keys{$b} cmp $keys{$a} } keys %keys) {
    #if the keycode is not found in the mapping using a generic name
    if (!defined $name{$key}) {
        $name{$key} = "KeyCode$key";
    }

    #simple listing: key_label=>frequency
    #print "$name{$key} ($key): $keys{$key}\n";

    #above with alignment of the values: key_label=>frequency
    #printf("%15s %d\n",$name{$key}." (".$key."):",$keys{$key});

    # above : with percentage
    printf("%16s %d (%.1f%s)\n",$name{$key}." (".$key."):",$keys{$key},$keys{$key}*100/$total,'%');
}

close LOGFILE;

