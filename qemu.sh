#!/bin/sh




KERNEL="bzImage"
INITRD="initramfs"



help () {
	echo "Runs a linux kernel image along with its initramfs in qemu"
	echo
	echo "Syntax: qemu.sh [-h|k|i]"
	echo "options:"
	echo "h		Prints this help"
	echo "k		Specifies a kernel image (default: ${KERNEL})"
	echo "i		Specifies an initramfs file (default: ${INITRD})"
}

while getopts "hk:i:" arg; do
	case $arg in
		h) help && exit		;;
		k) KERNEL=$OPTARG	;;
		i) INITRD=$OPTARG	;;
	esac
done



qemu-system-x86_64		\
	-kernel $KERNEL		\
	-initrd $INITRD		\
	-append "console=ttyS0"	\
	-nographic
