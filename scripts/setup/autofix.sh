#!/bin/bash
# Salvar este script na partição boot como autofix.sh

# Este script será executado automaticamente no boot
fsck -y /dev/mmcblk0p2
mount -o remount,rw /
touch /boot/fixed.txt
reboot
