# Makefile for usb_eject utility

CC      ?= gcc
CFLAGS  = -Wall -Wextra -std=c99 -pedantic
LDFLAGS =
TARGET  = usb_eject
SRCS    = usb_eject.c
OBJS    = $(SRCS:.c=.o)

LIBUSB_STATIC_FLAGS = $(shell pkg-config --cflags --libs --static libusb-1.0)
LIBUSB_A = /usr/local/Cellar/libusb/1.0.29/lib/libusb-1.0.a
LIBUSB_A_ARM = $(abspath ./libusb/1.0.29/lib/libusb-1.0.a)

.PHONY: all clean install-deps help

# ------------------- Build -------------------

all: install-deps $(TARGET)

$(TARGET)-static-current: 
	$(CC) $(CFLAGS) $(SRCS) -o $(TARGET)-current $(LDFLAGS) $(filter-out -lusb-1.0,$(LIBUSB_STATIC_FLAGS)) $(LIBUSB_A)

$(TARGET)-static-arm-onx64:
	$(CC) -arch arm64 $(CFLAGS) $(SRCS) -o $(TARGET)-arm64 $(LDFLAGS) $(filter-out -lusb-1.0,$(LIBUSB_STATIC_FLAGS)) $(LIBUSB_A_ARM)

$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS) $(shell pkg-config --libs libusb-1.0)

%.o: %.c
	$(CC) $(CFLAGS) $(shell pkg-config --cflags libusb-1.0) -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJS)

# ------------------- Dependencies -------------------

install-deps:
	bash ./scripts/install_deps.sh

install-macos-arm-deps:
	bash ./scripts/install_macos_arm_deps.sh
# ------------------- Help -------------------

help:
	@echo "Usage:"
	@echo "  make install-deps   Install dependencies (macOS / Debian)"
	@echo "  make                Build $(TARGET)"
	@echo "  make clean          Remove build artifacts"
