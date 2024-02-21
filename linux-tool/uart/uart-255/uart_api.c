
/* uart_api.c */
#include <stdio.h>//包含perror的头文件
#include <stdlib.h>
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <termios.h>
#include <errno.h>
#include "uart_api.h"

int open_port(char* com_port)
{
    int fd;

    fd = open(com_port, O_RDWR|O_NOCTTY|O_NDELAY);

    if (fd < 0){
        perror("open serial port");
        return(-1);
    }

    if (fcntl(fd, F_SETFL, 0) < 0){
        perror("fcntl F_SETFL\n");
    }

    if (isatty(STDIN_FILENO) == 0){
        perror("standard input is not a terminal device");
    }

    return fd;
}

int set_com_config(int fd,int baud_rate, int data_bits, char parity, int stop_bits)
{
    struct termios new_cfg,old_cfg;
    int speed;

    if  (tcgetattr(fd, &old_cfg)  !=  0){
        perror("tcgetattr");
        return -1;
    }


    new_cfg = old_cfg;
    cfmakeraw(&new_cfg);
    new_cfg.c_cflag &= ~CSIZE;

    switch (baud_rate){
    case 2400:
        speed = B2400;
        break;

    case 4800:
        speed = B4800;
        break;

    case 9600:
        speed = B9600;
        break;

    case 19200:
        speed = B19200;
        break;

    case 38400:
        speed = B38400;
        break;

    default:
    case 115200:
        speed = B115200;
        break;
    }
    cfsetispeed(&new_cfg, speed);
    cfsetospeed(&new_cfg, speed);

    switch (data_bits){
    case 7:
        new_cfg.c_cflag |= CS7;
        break;

    default:
    case 8:
        new_cfg.c_cflag |= CS8;
        break;
    }

    switch (parity){
    default:
    case 'n':
    case 'N':
        new_cfg.c_cflag &= ~PARENB;
        new_cfg.c_iflag &= ~INPCK;
        break;

    case 'o':
    case 'O':
        new_cfg.c_cflag |= (PARODD | PARENB);
        new_cfg.c_iflag |= INPCK;
        break;

    case 'e':
    case 'E':
        new_cfg.c_cflag |= PARENB;
        new_cfg.c_cflag &= ~PARODD;
        new_cfg.c_iflag |= INPCK;
        break;

    case 's':  /*as no parity*/
    case 'S':
        new_cfg.c_cflag &= ~PARENB;
        new_cfg.c_cflag &= ~CSTOPB;
        break;
    }

    switch (stop_bits){
    default:
    case 1:
        new_cfg.c_cflag &=  ~CSTOPB;
        break;

    case 2:
        new_cfg.c_cflag |= CSTOPB;
    }

    new_cfg.c_cc[VTIME]  = 0;
    new_cfg.c_cc[VMIN] = 1;

    tcflush(fd, TCIFLUSH);

    if((tcsetattr(fd, TCSANOW, &new_cfg)) != 0){
        perror("tcsetattr");
        return -1;
    }

    return 0;
}
