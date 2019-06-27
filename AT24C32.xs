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

int XS_init (uint8_t addr ){

    int fd;

    if ((fd = open("/dev/i2c-1", O_RDWR)) < 0) {
        close(fd);
        croak("Couldn't open the device: %s\n", strerror(errno));
	}

	if (ioctl(fd, I2C_SLAVE_FORCE, addr) < 0) {
        close(fd);
        croak(
            "Couldn't find device at addr %d: %s\n",
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

MODULE = RPi::RTC::DS3231  PACKAGE = RPi::RTC::DS3231

PROTOTYPES: DISABLE

void
setSeconds (fd, value)
    int fd
    int value

void
setMinutes (fd, value)
    int fd
    int value

void
setMilitary (fd, value)
    int fd
    int value

int
getMilitary (fd)
    int fd

void
setMeridien (fd, value)
    int fd
    int value

int
getMeridien (fd)
    int fd

int
getHour (fd)
	int	fd

int
getSeconds (fd)
    int fd

int
getMinutes (fd)
    int fd

void
setHour (fd, value)
    int fd
    int value

const char*
getDayOfWeek (fd)
    int fd

void
setDayOfWeek (fd, value)
    int fd
    int value

int
getDayOfMonth (fd)
    int fd

void
setDayOfMonth (fd, value)
    int fd
    int value

int getMonth (fd)
    int fd

void setMonth (fd, value)
    int fd
    int value

int getYear (fd)
    int fd

void setYear (fd, value)
    int fd
    int value

float getTemp (fd)
    int fd

int
getFh (rtcAddr)
    int rtcAddr

void
disableRegisterBit (fd, reg, bit)
	int	fd
	int	reg
	int	bit
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        disableRegisterBit(fd, reg, bit);
        if (PL_markstack_ptr != temp) {
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY;
        }
        return;

void
enableRegisterBit (fd, reg, bit)
	int	fd
	int	reg
	int	bit
        PREINIT:
        I32* temp;
        PPCODE:
        temp = PL_markstack_ptr++;
        enableRegisterBit(fd, reg, bit);
        if (PL_markstack_ptr != temp) {
          PL_markstack_ptr = temp;
          XSRETURN_EMPTY;
        }
        return;

int
getRegister (fd, reg)
	int	fd
	int	reg

int
getRegisterBit (fd, reg, bit)
	int	fd
	int	reg
	int	bit

int
getRegisterBits (fd, reg, msb, lsb)
	int	fd
	int	reg
	int	msb
	int	lsb

int
setRegister (fd, reg, value, name)
	int	fd
	int	reg
	int	value
	char*	name

int
setRegisterBits(fd, reg, lsb, nbits, value, name)
    int fd
    int reg
    int lsb
    int nbits
    int value
    char* name

void
_establishI2C (fd)
	int	fd

void
_close (fd)
    int fd
