use strict;
use warnings;

use Test::More;

use RPi::EEPROM::AT24C32;

my $e = RPi::EEPROM::AT24C32->new(delay => 2);

$e->write(100, 232);
is $e->read(100), 232, "single address write/read ok";

my $val = 100;

for (4080..4095){
    $e->write($_, $val);
    is $e->read($_), $val, "wrote val $val to addr $_ ok";
    $val++;
}

done_testing();
