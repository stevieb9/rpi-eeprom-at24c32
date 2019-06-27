use warnings;
use strict;
use feature 'say';

use Inline Config =>
           disable => clean_after_build =>
           name => 'RPi::EEPROM::AT24C32';
use Inline 'C';

use constant {
    EEPROM_ADDR => 0x57
};

my $fd = XS_init(EEPROM_ADDR);

say $fd;

__END__
__C__

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include <errno.h>
#include <fcntl.h>
#include <linux/i2c.h>
#include <linux/i2c-dev.h>
#include <sys/ioctl.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

int XS_init (int addr){

    int fd;

    if ((fd = open("/dev/i2c-1", O_RDWR)) < 0) {
        close(fd);
        croak("Couldn't open the EEPROM i2c device: %s\n", strerror(errno));
	}

	if (ioctl(fd, I2C_SLAVE_FORCE, addr) < 0) {
        close(fd);
        croak(
            "Couldn't find the EEPROM i2c device at addr %d: %s\n",
            addr,
            strerror(errno)
        );
	}

//    _establishI2C(fd);

    return fd;
}

void _establishI2C (int fd){
    /* CURRENTLY UNUSED */
    int buf[1] = { 0x00 };

    if (write(fd, buf, 1) != 1){
        close(fd);
		croak("Error: Received no ACK bit, couldn't establish connection!");
    }
}

void _close (int fd){
    close(fd);
}
