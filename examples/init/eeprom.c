/***************************************************************************
    copyright            : (C) by 2003-2004 Stefano Barbato
    email                : stefano@codesink.org

    Copyright (C) 2011 by Kris Rusocki <kszysiu@gmail.com>
    - support for user-defined write cycle time

    $Id: 24cXX.c,v 1.5 2004/02/29 11:05:28 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#include <stdio.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <linux/fs.h>
#include <sys/types.h>
#include <sys/ioctl.h>
#include <errno.h>
#include <assert.h>
#include <string.h>
#include "eeprom.h"

static int _writeAddress(struct eeprom *e, __u8 buf[2]){
	int r = i2c_smbus_write_byte_data(e->fd, buf[0], buf[1]);
	if(r < 0)
		fprintf(stderr, "Error _writeAddress: %s\n", strerror(errno));
	usleep(10);
	return r;
}

static int _writeByte(struct eeprom *e, __u8 buf[3])
{
	int r;
	r = i2c_smbus_write_word_data(e->fd, buf[0], buf[2] << 8 | buf[1]);
	if(r < 0)
		fprintf(stderr, "Error _writeByte: %s\n", strerror(errno));
	usleep(10);
	return r;
}

static int _writeBlock(struct eeprom *e, __u8 eepromAddr, __u8 len, __u8 *data)
{
	int r;
	r = i2c_smbus_write_block_data(e->fd, eepromAddr, len, data);
	if(r < 0)
		fprintf(stderr, "Error _write_block: %s\n", strerror(errno));
	usleep(10);
	return r;
}

int eeprom_init(char *dev_fqn, int addr, int type, int write_cycle_time, struct eeprom* e){
	int funcs, fd, r;
	e->fd = e->addr = 0;
	e->dev = 0;
	
	fd = open(dev_fqn, O_RDWR);
	if(fd <= 0)
	{
		fprintf(stderr, "Error eeprom_init: %s\n", strerror(errno));
		return -1;
	}

	// set working device
	if( ( r = ioctl(fd, I2C_SLAVE, addr)) < 0)
	{
		fprintf(stderr, "Error opening EEPROM i2c connection: %s\n", strerror(errno));
		return -1;
	}

	e->fd = fd;
	e->addr = addr;
	e->dev = dev_fqn;
	e->type = type;
	e->write_cycle_time = write_cycle_time;

	return 0;
}

int eeprom_close(struct eeprom *e){
	close(e->fd);
	e->fd = -1;
	e->dev = 0;
	e->type = EEPROM_TYPE_UNKNOWN;
	return 0;
}

int eeprom_read_current_byte(struct eeprom* e){
	ioctl(e->fd, BLKFLSBUF); // clear kernel read buffer
	return i2c_smbus_read_byte(e->fd);
}

int eeprom_read_byte(struct eeprom* e, __u16 mem_addr){
	int r;
	ioctl(e->fd, BLKFLSBUF); // clear kernel read buffer
	
	__u8 buf[2] = { (mem_addr >> 8) & 0x0ff, mem_addr & 0x0ff };

    r = _writeAddress(e, buf);
	
    if (r < 0){
		return r;
    }

    return(i2c_smbus_read_byte(e->fd));
}

int eeprom_write_byte(struct eeprom *e, __u16 mem_addr, __u8 data){
    __u8 buf[3] = {
        (mem_addr >> 8) & 0x00ff,
        mem_addr & 0x00ff,
        data 
    };

    int ret = _writeByte(e, buf);

    if (ret == 0 && e->write_cycle_time != 0) {
        usleep(1000 * e->write_cycle_time);
    }
    return ret;
}

int eeprom_write_block(struct eeprom *e, __u16 mem_addr, __u8 data){

    __u8 addr_msb = (mem_addr >> 8) & 0x00ff;
    __u8 buf[2] = {
        mem_addr & 0x00ff,
        data
    };

    int ret = _writeByte(e, buf);

    if (ret == 0 && e->write_cycle_time != 0) {
        usleep(1000 * e->write_cycle_time);
    }
    return ret;
}
