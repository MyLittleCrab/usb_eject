#!/usr/bin/env bash
set -e

UNAME_S=$(uname -s)

if [ "$UNAME_S" = "Darwin" ]; then
	echo "Installing dependencies for macOS..."
	if ! command -v brew >/dev/null 2>&1; then
		echo "Homebrew not found. Installing..."
		/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
	fi
	brew install libusb pkg-config
elif [ "$UNAME_S" = "Linux" ]; then
	echo "Installing dependencies for Debian/Ubuntu..."
	if command -v apt >/dev/null 2>&1; then
		sudo apt update
		sudo apt install -y libusb-1.0-0-dev pkg-config
	else
		echo "apt not found. Please install libusb-1.0-0-dev and pkg-config manually."
		exit 1
	fi
else
	echo "Unsupported OS: $UNAME_S. Install libusb-1.0 and pkg-config manually."
	exit 1
fi