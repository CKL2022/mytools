/* uart_ctrl.c */
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include "uart_api.h"

#include <sys/socket.h>
#include <sys/wait.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>
#include <sys/ioctl.h>

int  check_argc()
{
	printf("\t======================================\n");
	printf("\tExample:\n");
	printf("\tSend -> ./app-uart send /dev/ttymxcn\n");
	printf("\tRead -> ./app-uart read /dev/ttymxcn\n");
	printf("\tNote: for upon ttymxcn, [n] can be 1,2,3,4,5!\n");
	printf("\t======================================\n");
	return 1;
}


int main(int argc,char *argv[])
{
	int fd;
	char buff[BUFFER_SIZE];
	unsigned char witeBuff[] = "this is an uart test message :\r\n \
					1 1 1 1 1 1 1 1 1 1 \r\n \
					2 2 2 2 2 2 2 2 2 2 \r\n \
					3 3 3 3 3 3 3 3 3 3 \r\n \
					4 4 4 4 4 4 4 4 4 4 \r\n \
					5 5 5 5 5 5 5 5 5 5 \r\n \
					6 6 6 6 6 6 6 6 6 6 \r\n \
					1 2 3 4 5 6 7 8 9 0 \r\n ";
	unsigned char readBuff[255];

	int readnum = 0, recivenum = 0;
	int datanum = 0, writenum = 0;

	int j = 0;

printf("---mode:%s  port:%s------\r\n",argv[1],argv[2]);

	if(argc != 3)
	{
		check_argc();
		printf("please use as : ./app send /dev/ttyUSB0\r\n");
		return 1;
	}


	if((fd = open_port( argv[2] )) < 0) {
		printf("open_port %s\r\n",argv[2]);
		return 1;
	}
	
	if(set_com_config(fd, 115200, 8, 'N', 1) < 0)  {
		perror("set_com_config");
		return 1;
	}
	
	do{
		
		if( strstr(argv[1],"send") )
		{
			datanum = write(fd, witeBuff, sizeof(witeBuff));
			printf("Send_ok  datanum = %d   writenum = %d\n" , datanum,writenum++);
			sleep(3);
		}
		else if ( strstr(argv[1],"read") )
		{
		fd_set fs_read;
		int fs_sel = 0;
		struct timeval time;

		FD_ZERO(&fs_read);
		FD_SET(fd, &fs_read);
		time.tv_sec  = 1;	
		time.tv_usec = 0;
//		fs_sel=select(fd+1, &fs_read, NULL, NULL, &time);
		fs_sel=select(fd+1, &fs_read, NULL, NULL, NULL);
			if(fs_sel)
			{
				readnum = read(fd, readBuff, 254);
				for(j=0;j<readnum;j++){
					if(readBuff[j] == '!')
					{
						readBuff[j+1]= '\0';
//						printf("-recve- : %s |end\r\n", readBuff);
//						memset(readBuff,0,254);
					}
//					printf(" %c",readBuff[j]);
				}
					if(readBuff[j+1]== '\0')
					{
						printf("%s", readBuff);
						memset(readBuff,0,sizeof(readBuff));
					}
				}
				printf("\r\nRead_ok num = %d\r\n" , readnum++ );
			}
		else 
		{
			printf("please check your order\r\n");
			printf("argv[1]=%s\r\n",argv[1]);
			printf("strstr=%s\r\n",strstr(argv[1],"read"));
			return 1;
		}
		}
	while(1);

  	close(fd);
  	return 0;
}
//3720__RX
