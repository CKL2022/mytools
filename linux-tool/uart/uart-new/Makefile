CROSS_COMPILE=../../prebuilts/gcc/linux-x86/aarch64/gcc-arm-10.3-2021.07-x86_64-aarch64-none-linux-gnu/bin/aarch64-none-linux-gnu-
CC = $(CROSS_COMPILE)gcc
CFLAGS = -Wall -Wextra -O2
LDFLAGS = -shared

LIB_SOURCES = 
LIB_OBJECTS = $(LIB_SOURCES:.c=.o)
LIB_NAME = 

TEST_SOURCE = uart.c
TEST_OBJECT = $(TEST_SOURCE:.c=.o)
TEST_NAME = uart-test

.PHONY: all clean

all: $(LIB_NAME) $(TEST_NAME)

$(LIB_NAME): $(LIB_OBJECTS)
	$(CC) $(LDFLAGS) -o $@ $^

$(TEST_NAME): $(TEST_OBJECT) $(LIB_NAME)
	$(CC) $(CFLAGS) -o $@ $<

%.o: %.c
	$(CC) $(CFLAGS) -c -fPIC $< -o $@

clean:
	rm -f $(LIB_NAME) $(LIB_OBJECTS) $(TEST_NAME) $(TEST_OBJECT)

