#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>

int set_interface_attribs(int fd, int speed) {
    struct termios tty;
    if (tcgetattr(fd, &tty) != 0) {
        perror("Error from tcgetattr");
        return -1;
    }

    cfsetospeed(&tty, speed);
    cfsetispeed(&tty, speed);

    tty.c_cflag |= (CLOCAL | CREAD);    // Enable receiver and set local mode
    tty.c_cflag &= ~CSIZE;              // Mask character size bits
    tty.c_cflag |= CS8;                 // Set 8 data bits
    tty.c_cflag &= ~PARENB;             // Disable parity bit
    tty.c_cflag &= ~CSTOPB;             // Set 1 stop bit

    if (tcsetattr(fd, TCSANOW, &tty) != 0) {
        perror("Error from tcsetattr");
        return -1;
    }

    return 0;
}

int main(int argc, char *argv[]) {
	 
	if (argc < 3 || argc > 4) {
        printf("Usage: %s send <serial_port> [message]\n", argv[0]);
        printf("       %s recv <serial_port>\n", argv[0]);
        return -1;
    }
    char *mode = argv[1];
    char *port = argv[2];

    int fd;

    if (strcmp(mode, "send") == 0 && argc == 4) {
		char *message = argv[3];
        fd = open(port, O_WRONLY | O_NOCTTY);
        if (fd == -1) {
            perror("Error opening serial port for sending");
            return -1;
        }

        if (set_interface_attribs(fd, B115200) != 0) {
            return -1;
        }

        // Send data to serial port
        char data[255];
        snprintf(data, sizeof(data), "Serial Port:%s\r\nMessages:%s\r\n\r\n", port, message);
        size_t bytes_written = write(fd, data, strlen(data));
        if (bytes_written != strlen(data)) {
            perror("Error writing to serial port");
            return -1;
        }

        close(fd);
    } else if (strcmp(mode, "recv") == 0 && argc == 3) {
        fd = open(port, O_RDONLY | O_NOCTTY | O_NDELAY);
        if (fd == -1) {
            perror("Error opening serial port for receiving");
            return -1;
        }

        if (set_interface_attribs(fd, B115200) != 0) {
            return -1;
        }

        fcntl(fd, F_SETFL, 0);


    char buf[255];
    while (1) {
        // Read data from serial port
        ssize_t bytes_read = read(fd, buf, sizeof(buf));
        if (bytes_read > 0) {
            // Check if buf array is not empty
            int is_empty = 1;
            for (int i = 0; i < bytes_read; i++) {
                if (buf[i] != '\n') { //do not use '\0'
                    is_empty = 0;
                    break;
                }
            }

            if (!is_empty) {
                printf("bytes_read: %ld\n", bytes_read-1);
                printf("Received data: %s\n", buf);
            }

            bytes_read = 0;
            memset(buf, 0, sizeof(buf));  // 清空buf数组
        }
        else if (bytes_read < 0) {
            perror("Error reading from serial port");
        }
    }


        close(fd);
    } else {
        printf("Invalid mode. Please use 'send' or 'recv'.\n");
        return -1;
    }

    return 0;
}

