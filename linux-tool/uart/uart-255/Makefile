EXEC = app-uart
OBJS = uart_ctrl.o uart_api.o
HEADERS = uart_api.h

#CC=arm-rockchip830-linux-uclibcgnueabihf-gcc
CC = $(CROSS_COMPILE)gcc


all:${EXEC}
${EXEC} : ${OBJS}
	${CC} ${CFLAGS} ${LDFLAGS} -o $@ ${OBJS} 
${OBJS2} : ${HEADERS}

.PHONY : clean
clean :
	-rm -f ${OBJS} ${EXEC}
