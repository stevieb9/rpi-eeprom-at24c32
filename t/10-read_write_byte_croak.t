use strict;
use warnings;

use RPi::EEPROM::AT24C32;
use Test::More;

my $e = RPi::EEPROM::AT24C32->new;

for (-1, 4096){
    is
        eval { $e->read($_); 1 },
        undef,
        "read() with $_ as addr param fails";

    is
        eval { $e->write($_, 255); 1 },
        undef,
        "write() with $_ as addr param fails";
}

for (-1, 256){
    is
        eval { $e->write(4095, $_); 1 },
        undef,
        "write() with $_ as byte param fails";
}

done_testing();

