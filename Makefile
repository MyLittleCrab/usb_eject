# Makefile for usb_eject utility

CC      ?= cc
CFLAGS  = -Wall -Wextra -std=c99 -pedantic
LDFLAGS =
TARGET  = usb_eject
SRCS    = usb_eject.c
OBJS    = $(SRCS:.c=.o)

UNAME_S := $(shell uname -s)

.PHONY: all clean install-deps help

# ------------------- Build -------------------

all: $(TARGET)

$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $@ $(LDFLAGS) $(shell pkg-config --libs libusb-1.0)

%.o: %.c
	$(CC) $(CFLAGS) $(shell pkg-config --cflags libusb-1.0) -c $< -o $@

clean:
	rm -f $(TARGET) $(OBJS)

# ------------------- Dependencies -------------------

install-deps:
	@if [ "$(UNAME_S)" = "Darwin" ]; then \
		echo "Installing dependencies for macOS..."; \
		if ! command -v brew >/dev/null 2>&1; then \
			echo "Homebrew not found. Installing..."; \
			/bin/bash -c "$$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
		fi; \
		brew install libusb pkg-config; \
	elif [ "$(UNAME_S)" = "Linux" ]; then \
		echo "Installing dependencies for Debian/Ubuntu..."; \
		if command -v apt >/dev/null 2>&1; then \
			sudo apt update && sudo apt install -y libusb-1.0-0-dev pkg-config; \
		else \
			echo "apt not found. Please install libusb-1.0-0-dev and pkg-config manually."; \
			exit 1; \
		fi; \
	else \
		echo "Unsupported OS: $(UNAME_S). Install libusb-1.0 and pkg-config manually."; \
		exit 1; \
	fi

# ------------------- Help -------------------

help:
	@echo "Usage:"
	@echo "  make install-deps   Install dependencies (macOS / Debian)"
	@echo "  make                Build $(TARGET)"
	@echo "  make clean          Remove build artifacts"
