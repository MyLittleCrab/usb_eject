#!/usr/bin/env bash

cc usb_eject.c -o usb_eject \
  -I$(brew --prefix libusb)/include/libusb-1.0 \
  -L$(brew --prefix libusb)/lib \
  -Wl,-rpath,$(brew --prefix libusb)/lib \
  -lusb-1.0

