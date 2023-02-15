#!/bin/sh




KERNEL="vmlinuz"
INITRAMFS="initramfs"
ENTRY_NAME="Linux Custom"
KERNEL_PARAMS=""
OUTPUT_TAR="bootable.tar.gz"
GRUB_ROM="grub-efi.tar.gz"



help () {
cat <<EOF
Builds GRUB and sets up a configuration file

Syntax: build.sh [-h|k|i|p]
options:

	h		Prints this help
	k		Specifies a kernel image (default: "$KERNEL")
	i		Specifies an initramfs image (default: "$INITRAMFS")
	n		Specifies an entry name (default: "$ENTRY_NAME")
	p		Specifies kernel parameters (default: UNSET)
	o		Specifies an output tar archive (default: "$OUTPUT_TAR")
	g		Specifies a grub rom (default "$GRUB_ROM")

EOF
exit 0
}


while getopts "hk:i:n:p:o:g:" arg; do
	case $arg in
		h) help && exit		;;
		k) KERNEL=$OPTARG	;;
		i) INITRAMFS=$OPTARG	;;
		n) ENTRY_NAME=$OPTARG	;;
		p) KERNEL_PARAMS=$OPTARG;;
		o) OUTPUT_TAR=$OPTARG	;;
		g) GRUB_ROM=$OPTARG	;;
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

	tar xvf $GRUB_ROM

	mv efi.img boot/grub/
	mv bootx64.efi efi/boot

	cp $1 boot/vmlinuz && cp $2 boot/initramfs
}


generate_grubconfig () {
	mkdir -p boot/grub/
	touch boot/grub/grub.cfg

cat > boot/grub/grub.cfg <<EOF
set timeout=1

menuentry "$3" {
	linux /boot/vmlinuz $4
	initrd /boot/initramfs
}
EOF
}



populate_filestructure $KERNEL $INITRAMFS
generate_grubconfig $KERNEL $INITRAMFS "$ENTRY_NAME" "$KERNEL_PARAMS"

tar czvf $OUTPUT_TAR boot/ efi/
rm -rf boot/ efi/
