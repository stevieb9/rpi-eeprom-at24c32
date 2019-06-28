package RPi::EEPROM::AT24C32;

use strict;
use warnings;

use Carp qw(croak);
use Data::Dumper;

our $VERSION = '0.01';

require XSLoader;
XSLoader::load('RPi::EEPROM::AT24C32', $VERSION);

sub new {
    my ($class, %args) = @_;


    $args{device}  //= '/dev/i2c-1';
    $args{address} //= 0x57;
    $args{delay}   //= 1;

    return bless {%args}, $class;
}
sub dump {
    print Dumper shift;
}

1;
__END__

=head1 NAME

RPi::EEPROM::AT24C32 - Read and write to the AT24C32/64 based EEPROM ICs

=head1 DESCRIPTION

=head1 SYNOPSIS

=head1 METHODS

=head1 AUTHOR

Steve Bertrand, C<< <steveb at cpan.org> >>

=head1 LICENSE AND COPYRIGHT

Copyright 2019 Steve Bertrand.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

1; # End of RPi::EEPROM::AT24C32
