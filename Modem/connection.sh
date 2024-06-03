#!/bin/bash

# Define variables for modem type selection
export OTHER=USBMODEM
export USBMODEM=3
#export APN=www
export APN_USER=subarna
export APN_PASS=1234

# Execute the commands
lsusb | grep 05c6
sudo usb_modeswitch -c /etc/usb_modeswitch.conf
sleep 5
lsusb | grep 05c6
/home/subarna/sakis3g --sudo --interactive "connect" OTHER="$OTHER" USBMODEM=05c6:9201 USBINTERFACE=1 USBDRIVER="option>
