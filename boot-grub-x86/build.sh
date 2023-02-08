#!/bin/sh




KERNEL="vmlinuz"
INITRAMFS="initramfs"
ENTRY_NAME="Linux Custom"
KERNEL_PARAMS=""
OUTPUT_TAR="bootable.tar.gz"



help () {
cat <<EOF
Builds a minimal linux kernel and makes a minimal root filesystem from a custom payload

Syntax: build.sh [-h|k|i|p]
options:

	h		Prints this help
	k		Specifies a kernel image (default: "$KERNEL")
	i		Specifies an initramfs image (default: "$INITRAMFS")
	n		Specifies an entry name (default: "$ENTRY_NAME")
	p		Specifies kernel parameters (default: UNSET)
	o		Specifies an output tar archive (default: "$OUTPUT_TAR")
EOF
exit 0
}


while getopts "hk:i:n:p:o:" arg; do
	case $arg in
		h) help && exit		;;
		k) KERNEL=$OPTARG	;;
		i) INITRAMFS=$OPTARG	;;
		n) ENTRY_NAME=$OPTARG	;;
		p) KERNEL_PARAMS=$OPTARG;;
		o) OUTPUT_TAR=$OPTARG	;;
	esac
done


testfile () {
	if [ ! -f $1 ]
	then
		echo "File $1 not found, exitting"
		exit 1
	fi
}


populate_filestructure () {
	testfile $1 && testfile $2

	mkdir -p \
		efi/boot \
		boot/grub

	tar xvf grub-efi.tar.gz

	mv efi.img boot/grub/
	mv bootx64.efi efi/boot

	cp $1 boot/ && cp $2 boot/
}


generate_grubconfig () {
	mkdir -p boot/grub/
	touch boot/grub/grub.cfg

cat > boot/grub/grub.cfg <<EOF
set timeout=1

menuentry "$3" {
	linux /boot/$1 $4
	initrd /boot/$2
}
EOF
}



populate_filestructure $KERNEL $INITRAMFS
generate_grubconfig $KERNEL $INITRAMFS "$ENTRY_NAME" "$KERNEL_PARAMS"

tar czvf $OUTPUT_TAR boot/ efi/
rm -rf boot/ efi/
