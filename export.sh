#!/bin/sh





OUT_DEV=""
INITRAMFS_BUILDER="kernel-build-scripts/build.sh"
ROOTFS="rootfs"
GRUB_BUILDER="boot-grub-x86/build.sh"
GRUB_ROM="boot-grub-x86/grub-efi.tar.gz"



help () {
cat <<EOF
Exports a kernel build, root file system (initramfs) and grub configuration to disk

Syntax: ./export.sh [-h|o]
options:
	
	h	Prints this help
	d	Specifies an output device (default: UNSET)

EOF
exit 0
}



while getopts "hd:" arg; do
	case $arg in
		h) help ;;
		d) OUT_DEV=$OPTARG
	esac
done


clean () { 
	rm -rf boot/ efi/ bootable.tar.gz initramfs 
}

testfile () {
	if [ ! -f $1 ]
	then
		echo "File $1 not found, exitting"
		clean
		exit 1
	fi
}

testvar () {
	if [ -z $1 ]
	then
		echo "Variable $2 unset, exitting"
		clean
		exit 1
	fi

}


build_archive () {
	$local/$INITRAMFS_BUILDER -i $local/vmlinuz.bak -r $local/$ROOTFS
	$local/$GRUB_BUILDER -k $local/vmlinuz.bak -i initramfs -g $local/$GRUB_ROM
}


setup_disk () {
	testvar "$1" "output device"

	read -p "Warning, the following disk will be overwritten: $1, proceed [Y/n]: " response
	case $response in
		[yY]) continue ;;
		*) clean && exit 0
	esac

	testfile bootable.tar.gz

	mount $1 /mnt
	cp bootable.tar.gz /mnt

	cd /mnt
	rm -r boot/ efi/
	tar xvf bootable.tar.gz
	rm bootable.tar.gz
	cd $local
	
	umount /mnt
}


local=$(pwd)
cd /tmp

build_archive 
setup_disk $OUT_DEV
clean
