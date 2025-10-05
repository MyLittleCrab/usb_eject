#!/usr/bin/env bash
set -e

if ! [ -d "./libusb" ]; then
    echo "libusb directory does not exist. Fetching and extracting libusb for ARM architecture..."
    brew fetch --force --arch=arm libusb
    cp $(brew --cache)/libusb-* .

    tar -xvf libusb-*

else
    echo "libusb directory already exists. Skipping fetch and extract."
fi