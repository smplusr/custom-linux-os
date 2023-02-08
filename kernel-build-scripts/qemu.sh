#!/bin/sh




KERNEL="vmlinuz"
INITRD="initramfs"



help () {
cat <<EOF
Runs a linux kernel image along with its initramfs in qemu

Syntax: qemu.sh [-h|k|i]
options:

	h	Prints this help
	k	Specifies a kernel image (default: ${KERNEL})
	i	Specifies an initramfs file (default: ${INITRD})
EOF
exit 0
}


while getopts "hk:i:" arg; do
	case $arg in
		h) help && exit		;;
		k) KERNEL=$OPTARG	;;
		i) INITRD=$OPTARG	;;
	esac
done


testfile () {
	if [ ! -f $1 ]
	then
		echo "File $1 not found, exitting"
		exit 1
	fi
}


qemu_run () {
	qemu-system-x86_64		\
		-kernel $1		\
		-initrd $2		\
		-append "console=ttyS0"	\
		-nographic
}



testfile $KERNEL
testfile $INITRD
qemu_run $KERNEL $INITRD
