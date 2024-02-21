/* uart_api.h */
#ifndef		UART_API_H
#define     	UART_API_H

//#define		GNR_COM			0
//#define		USB_COM			1
//#define 	COM_TYPE		GNR_COM
//#define 	MAX_COM_NUM		3
//#define		HOST_COM_PORT		1
//#define 	BUFFER_SIZE		1024
//#define 	BUFFER_SIZE	    256
#define 	BUFFER_SIZE	    2

int open_port(char* com_port);
int set_com_config(int fd,int baud_rate, int data_bits, char parity, int stop_bits);

#endif /* UART_API_H */
