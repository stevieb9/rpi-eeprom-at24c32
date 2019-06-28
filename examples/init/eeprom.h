/***************************************************************************
    copyright            : (C) by 2003-2004 Stefano Barbato
    email                : stefano@codesink.org

    Copyright (C) 2011 by Kris Rusocki <kszysiu@gmail.com>
    - support for user-defined write cycle time

    $Id: 24cXX.h,v 1.6 2004/02/29 11:05:28 tat Exp $
 ***************************************************************************/

/***************************************************************************
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 ***************************************************************************/
#ifndef _EEPROM_H_
#define _EEPROM_H_
#include "i2c-dev.h"

#define EEPROM_TYPE_UNKNOWN	0
#define EEPROM_TYPE_8BIT_ADDR	1
#define EEPROM_TYPE_16BIT_ADDR 	2

/*
 * opens the eeprom device at [dev_fqn] (i.e. /dev/i2c-N) whose address is
 * [addr] and set the eeprom_24c32 [e]
 */
int eeprom_init(char *dev_fqn, int addr, int delay);
/*
 * closees the eeprom device [e] 
 */
int eeprom_close(int fd);
/*
 * read and returns the eeprom byte at memory address [mem_addr] 
 * Note: eeprom must have been selected by ioctl(fd,I2C_SLAVE,address) 
 */
int eeprom_read_byte(int fd, int mem_addr);
/*
 * read the current byte
 * Note: eeprom must have been selected by ioctl(fd,I2C_SLAVE,address) 
 */
int eeprom_read_current_byte(int fd);
/*
 * writes [data] at memory address [mem_addr] 
 * Note: eeprom must have been selected by ioctl(fd,I2C_SLAVE,address) 
 */
int eeprom_write_byte(int fd, int mem_addr, int data);

int eeprom_write_block(int fd, int mem_addr, int data);

#endif

