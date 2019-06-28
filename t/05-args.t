use strict;
use warnings;

use Test::More;

use RPi::EEPROM::AT24C32;

my $e = RPi::EEPROM::AT24C32->new;

is ref $e, 'RPi::EEPROM::AT24C32', "object is of proper class";
is $e->{address}, 0x57, "default i2c address ok";
is $e->{device}, '/dev/i2c-1', "default i2c device ok";
is $e->{delay}, 1, "default delay ok";

done_testing();

