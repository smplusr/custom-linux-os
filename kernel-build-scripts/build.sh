#!/bin/sh




KERNEL="linux-6.1.9"
IMAGE="vmlinuz"
IMAGE_PATH="$KERNEL/arch/x86/boot/"
ROOTFS=""



help () {
cat <<EOF
Builds a minimal linux kernel and makes a minimal root filesystem from a custom payload

Syntax: build.sh [-h|k|i|p]
options:

	h		Prints this help
	k		Specifies a kernel (default: "$KERNEL")
	i		Specifies an image (default: "$IMAGE")
	r		Specifies a root filesystem (default: UNSET)
EOF
exit 0
}

while getopts "hk:i:r:" arg; do
	case $arg in
		h) help && exit		;;
		k) KERNEL=$OPTARG	;;
		i) IMAGE=$OPTARG	;;
		r) ROOTFS=$OPTARG	;;
	esac
done



build_kernel () {
	if [ ! -f $2 ]
	then
		local=$(pwd)

		if [ ! -f $3 ]
		then
	
			if [ ! -d $1 ]
		then
			if [ ! -f $1.tar.xz ]
				then
					echo "$1.tar.xz not found, downloading..."
					wget "https://cdn.kernel.org/pub/linux/kernel/v${1:6:1}.x/$1.tar.xz"
				fi
				
				echo "extracting $local/$1.tar.xz"
				tar xvf $local/$1.tar.xz
			fi
	
			echo "building $3"
		
			cd $1
			make mrproper
	
			read -p "Enter kernel configuration menu [Y/n]: " response
			case $response in
				[yY]) make menuconfig ;;
			esac
	
			make -j"$(nproc)" vmlinux bzImage
			cd $local
			
		else
			echo "$3 already build, skipping..."
		fi
	
		cp $3 $local/$2
	fi
}


build_initramfs () {	
	if [ ! -d $1 ]
	then
		echo "please provide a valid root filesystem"
		exit 1
	fi
	
	local=$(pwd)

	cd $1

	chmod +x *

	echo "Building init RAM filesystem with following files:"
	find .

	find . | cpio -o -H newc | gzip > $local/initramfs
	cd $local
}




build_kernel $KERNEL $IMAGE $IMAGE_PATH
build_initramfs $ROOTFS
