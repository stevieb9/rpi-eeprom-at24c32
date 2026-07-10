use strict;
use warnings;

use RPi::EEPROM::AT24C32;
use Test::More;

# HW-free coverage of the 1.00 changes: the broken eeprom_write_block() export
# was removed, and the V7 cleanup removed the dead _writeBlock() helper plus the
# orphaned eeprom_close()/eeprom_read_current_byte() XS exports. The address and
# byte validators croak before any i2c, so they run without a chip on the bus.

my $mod = 'RPi::EEPROM::AT24C32';

# Removed XS surface: none of these may be callable anymore.
for my $gone (qw(eeprom_write_block eeprom_close eeprom_read_current_byte)) {
    ok(! $mod->can($gone), "$gone removed (not callable)");
}

# XS surface the OO layer still relies on.
for my $kept (qw(eeprom_init eeprom_read eeprom_write)) {
    ok($mod->can($kept), "$kept still present");
}

# OO API surface.
for my $method (qw(new fd read write)) {
    can_ok($mod, $method);
}

# _check_addr: undef, below range, above range croak; boundaries pass.
eval { $mod->can('_check_addr')->('read', undef) };
like($@, qr/requires an EEPROM memory address/, 'undef addr croaks');

eval { $mod->can('_check_addr')->('read', -1) };
like($@, qr/out of range/, 'addr -1 (below min) croaks');

eval { $mod->can('_check_addr')->('read', 4096) };
like($@, qr/out of range/, 'addr 4096 (above max) croaks');

is($mod->can('_check_addr')->('read', 0), 1, 'addr 0 (min) passes');
is($mod->can('_check_addr')->('read', 4095), 1, 'addr 4095 (max) passes');

# _check_byte: undef, below range, above range croak; boundaries pass.
eval { $mod->can('_check_byte')->('write', undef) };
like($@, qr/requires a data byte/, 'undef byte croaks');

eval { $mod->can('_check_byte')->('write', -1) };
like($@, qr/out of range/, 'byte -1 (below min) croaks');

eval { $mod->can('_check_byte')->('write', 256) };
like($@, qr/out of range/, 'byte 256 (above max) croaks');

is($mod->can('_check_byte')->('write', 0), 1, 'byte 0 (min) passes');
is($mod->can('_check_byte')->('write', 255), 1, 'byte 255 (max) passes');

# new() croaks (rather than returning a broken fd=-1 object) when eeprom_init
# fails. A nonexistent device makes open() fail HW-free; suppress the C-layer's
# diagnostic on stderr so the test output stays clean.
my $init_err;
{
    local *STDERR;
    open STDERR, '>', '/dev/null';
    eval { $mod->new(device => '/dev/rpi-eeprom-nonexistent-test') };
    $init_err = $@;
}
like($init_err, qr/failed to initialise the EEPROM/, 'new() croaks when i2c init fails (not a broken fd=-1 object)');

done_testing;
