#!/bin/bash
#烧写nandflash方法: 
#tftp 0x30000000 ubifs.img
#nand erase.part rootfs
#nand write.i 0x30000000 root 文件大小
mkfs.ubifs -r ubifs -m 2048 -e 129024 -c 812 -o mini2440fs.img
ubinize -o ubifs.img -m 2048 -p 128KiB -s 512 ubinize.cfg
