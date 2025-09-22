# Makefile for usb_eject utility

# Define the C compiler. 'cc' usually points to 'clang' on macOS and 'gcc' on Linux.
CC ?= cc
# Standard compilation flags
CFLAGS = -Wall -Wextra -std=c99 -pedantic
# Linker flags
LDFLAGS =

# Target executable name
TARGET = usb_eject
# Source files
SRCS = usb_eject.c
# Object files derived from source files
OBJS = $(SRCS:.c=.o)

.PHONY: all clean install-deps

# Default target: builds the executable
all: $(TARGET)

# --- OS-SPECIFIC CONFIGURATION AND DEPENDENCY INSTALLATION ---

# Detect the operating system
UNAME_S := $(shell uname -s)

# Try to get libusb flags using pkg-config first
# Redirect stderr to /dev/null to suppress warnings if not found
PKG_CF_CFLAGS := $(shell pkg-config --cflags libusb-1.0 2>/dev/null)
PKG_CF_LIBS := $(shell pkg-config --libs libusb-1.0 2>/dev/null)

ifeq ($(UNAME_S), Darwin) # macOS
    # If pkg-config didn't find it, try Homebrew path directly
    ifeq ($(strip $(PKG_CF_CFLAGS)),)
        BREW_PREFIX := $(shell brew --prefix libusb 2>/dev/null)
        ifeq ($(strip $(BREW_PREFIX)),)
            # Fallback to common macOS paths if Homebrew is not found or libusb is not installed via it
            ALL_CFLAGS = $(CFLAGS) -I/usr/local/include/libusb-1.0
            ALL_LIBS = $(LDFLAGS) -L/usr/local/lib -lusb-1.0
        else
            ALL_CFLAGS = $(CFLAGS) -I$(BREW_PREFIX)/include/libusb-1.0
            ALL_LIBS = $(LDFLAGS) -L$(BREW_PREFIX)/lib -lusb-1.0
        endif
    else
        # pkg-config found libusb, use its output
        ALL_CFLAGS = $(CFLAGS) $(PKG_CF_CFLAGS)
        ALL_LIBS = $(LDFLAGS) $(PKG_CF_LIBS)
    endif

    install-deps:
        @echo "Installing dependencies for macOS..."
        # Check for Homebrew and install if not found
        if ! command -v brew > /dev/null 2>&1; then \
            echo "Homebrew not found. Installing Homebrew..."; \
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"; \
        fi
        brew update
        # Check for libusb and install if not found
        if ! brew list libusb > /dev/null 2>&1; then \
            echo "libusb not found. Installing libusb..."; \
            brew install libusb pkg-config; \
        else \
            echo "libusb already installed."; \
        fi
        @echo "All dependencies for macOS installed. You might need to run 'make clean all' again to apply new paths."

else ifeq ($(UNAME_S), Linux) # Linux (Debian-like assumed)
    # If pkg-config didn't find it, provide common Linux paths
    ifeq ($(strip $(PKG_CF_CFLAGS)),)
        ALL_CFLAGS = $(CFLAGS) -I/usr/include/libusb-1.0
        ALL_LIBS = $(LDFLAGS) -L/usr/lib -lusb-1.0
    else
        # pkg-config found libusb, use its output
        ALL_CFLAGS = $(CFLAGS) $(PKG_CF_CFLAGS)
        ALL_LIBS = $(LDFLAGS) $(PKG_CF_LIBS)
    endif

    install-deps:
        @echo "Installing dependencies for Linux (Debian-like). This may require root privileges..."
        # Check for apt and install libusb-1.0-0-dev and pkg-config
        if command -v apt > /dev/null 2>&1; then \
            sudo apt update; \
            sudo apt install -y pkg-config libusb-1.0-0-dev; \
        else \
            echo "apt not found. Please install libusb-1.0-0-dev and pkg-config manually for your distribution."; \
            exit 1; \
        fi
        @echo "All dependencies for Linux installed. You might need to run 'make clean all' again to apply new paths."

else # Other / Unknown OS
    ALL_CFLAGS = $(CFLAGS)
    ALL_LIBS = $(LDFLAGS) -lusb-1.0 # Basic libusb link, might need manual path adjustments

    install-deps:
        @echo "Unsupported operating system: $(UNAME_S)."
        @echo "Please install libusb-1.0 development headers and libraries, and pkg-config manually."
        exit 1
endif

# --- GENERAL BUILD RULES ---

# Rule to link object files into the executable
$(TARGET): $(OBJS)
	$(CC) $(OBJS) -o $@ $(ALL_LIBS)

# Rule to compile C source files into object files
%.o: %.c
	$(CC) $(ALL_CFLAGS) -c $< -o $@

# Target to clean up build artifacts
clean:
	rm -f $(TARGET) $(OBJS)
