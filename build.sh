#!/bin/sh




KERNEL="linux-6.1.9"
IMAGE="bzImage"
IMAGE_PATH="${KERNEL}/arch/x86/boot/"
ROOTFS="rootfs"
#PAYLOAD=""



help () {
	echo "Builds a minimal linux kernel and makes a minimal root filesystem from a custom payload"
	echo
	echo "Syntax: build.sh [-h|k|i|p]"
	echo "options:"
	echo "h		Prints this help"
	echo "k		Specifies a kernel (default: ${KERNEL})"
	echo "i		Specifies an image (default: ${IMAGE})"
	echo "r		Specifies a root filesystem (default: ${ROOTFS})"
	#echo "p		Specifies a payload (default: ${PAYLOAD})"
}

while getopts "hk:i:r:" arg; do
	case $arg in
		h) help && exit		;;
		k) KERNEL=$OPTARG	;;
		i) IMAGE=$OPTARG	;;
		r) ROOTFS=$OPTARG	;;
		#p) PAYLOAD=$OPTARG	;;
	esac
done



if [ ! -f ${IMAGE} ]
then
	if [ ! -f ${IMAGE_PATH} ]
	then

		if [ ! -d ${KERNEL} ]
		then
			if [ ! -f ${KERNEL}.tar.xz ]
			then
				echo "${KERNEL}.tar.xz not found, downloading..."
				wget "https://cdn.kernel.org/pub/linux/kernel/v${KERNEL:6:1}.x/${KERNEL}.tar.xz"
			fi
			
			echo "extracting ${KERNEL}.tar.xz"
			tar xvf ${KERNEL}.tar.xz
		fi

		echo "building ${IMAGE_PATH}"
		
		cd ${KERNEL}
		make mrproper defconfig -j"$(nproc)" all
		cd ../
		
	else
		echo "${IMAGE_PATH} already build, skipping..."
	fi

	cp ${IMAGE_PATH} ${IMAGE}
fi



if [ ! -f "initramfs" ]
then
	
#	if [ ! -d "rootfs" ]
#		then mkdir "rootfs"
#		cd "rootfs"
#		mkdir bin dev etc proc var tmp usr mnt sys
#		cd ../
#	fi
#	if [ -z ${PAYLOAD} ]
#	then
#		echo "building rootfs without any payload provided."
#	else
#		if [ ! -f ${PAYLOAD}]
#		then
#			echo "Please provide a valid payload."
#			exit 1
#		else
#			cp ${PAYLOAD} "rootfs/init"
#				chmod +x "rootfs/init"
#		fi
#	fi
#
#	cd rootfs
#	find . | cpio -o -H newc | gzip > ../initramfs
#	cd ../
	
	
	
	if [ ! -d ${ROOTFS} ]
		echo "please provide a valid root filesystem"
		exit 1
	fi
	
	cd ${ROOTFS}
	find . | cpio -o -H newc | gzip > ../initramfs
	cd ../
	
else
	echo "initramfs already build, skipping..."
fi

echo "done."	
