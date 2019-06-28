use strict;
use warnings;

use RPi::EEPROM::AT24C32;
use Test::More;

my $e = RPi::EEPROM::AT24C32->new;

# read w/o addr

is
    eval { $e->read(); 1 },
    undef,
    "read() without addr param fails";

like $@, qr/requires an EEPROM memory address/, "...and error is sane";

# write w/o addr

is
    eval { $e->write(); 1 },
    undef,
    "write() without addr param fails";

like $@, qr/requires an EEPROM memory address/, "...and error is sane";

# write w/o byte

is
    eval { $e->write(100); 1 },
    undef,
    "write() without byte param fails";

like $@, qr/requires a data byte/, "...and error is sane";

for (-1, 4096){
    is
        eval { $e->read($_); 1 },
        undef,
        "read() with $_ as addr param fails";

    like $@, qr/address parameter out of range/, "...and error is sane";

    is
        eval { $e->write($_, 255); 1 },
        undef,
        "write() with $_ as addr param fails";

    like $@, qr/address parameter out of range/, "...and error is sane";
}

for (-1, 256){
    is
        eval { $e->write(4095, $_); 1 },
        undef,
        "write() with $_ as byte param fails";

    like $@, qr/byte parameter out of range/, "...and error is sane";
}

done_testing();

