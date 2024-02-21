#!/bin/bash

#check arg number
if [ $# != 1 ];then
    echo "Usage: ./mksd.sh /dev/sdb "
    exit
fi

# check the if root?
userid=`id -u`
if [ $userid -ne "0" ]; then
echo "you're not root?"
exit
fi


#check image file exist or not?
files=`ls ../image/`
if [ -z "$files" ]; then
	echo "There are no file in image folder."
	exit
fi

node=$1
#check if /dev/sdx exist?
if [ ! -e ${node} ]; then
echo "There is no "${node}" in you system"
exit
fi

#avoid format my computer
if [ "$1" == "/dev/sda" ];then
        echo "cannot format your filesystem"
        exit
fi

if [ ${node} == "/dev/sdb" ];then
	echo "注意/dev/sdb 是否是你挂载的硬盘"
fi

echo "All data on "${node}" now will be destroyed! Continue? [y/n]"

read ans
if [ $ans != 'y' ]; then exit 1; fi

# umount device
umount ${node}* &> /dev/null

# destroy the partition table
dd if=/dev/zero of=${node} bs=1k count=2 conv=fsync &> /dev/null;sync

#partition
echo "partitionfile start"

cat << END | fdisk -H 255 -S 63 $node
n
p
1
10592
+64M
Y
n
p
2
141312

t
1
c
a
1
w
END

sync
fdisk -l
echo "partitionfile done"

PARTITION1=${node}1
if [ ! -b ${PARTITION1} ]; then
        PARTITION1=${node}1
fi

PARTITION2=${node}2
if [ ! -b ${PARTITION2} ]; then
        PARTITION2=${node}2
fi

echo "格式化 ${node}1 ..."
if [ -b ${PARTITION1} ]; then
	mkfs.vfat -F 32 -n "boot" ${PARTITION1}
#	sync
#	lsblk  -f
else
	echo "错误: /dev下找不到 SD卡 boot分区"
fi

echo "格式化${node}2 ..."
if [ -b ${PARITION2} ]; then
	mkfs.ext4 -F -L "rootfs" ${PARTITION2}
else
	echo "错误: /dev下找不到 SD卡 rootfs分区"
fi

sync
sync
echo "正在烧写Uboot到${node}"
dd if=../image/u-boot.imx of=$node bs=1k seek=33 conv=fsync
sync

echo "正在复制设备树与内核到${node}1，请稍候..."
umount mount_point0 &> /dev/null
rm -fr mount_point0 &> /dev/null
mkdir mount_point0

sync
sync

#if ! mount  ${node}1 mount_point0 &> /dev/null; then 
if ! mount  ${node}1 mount_point0 ; then 
	echo  "Cannot mount ${node}1"
	exit 1
fi

rm -fr mount_point0/*
echo "copy [Image & dtb]"
cp -f ../image/Image mount_point0/
cp -f ../image/*.dtb mount_point0/
chown -R 0.0 mount_point0/*

sync
sync

umount ${node}1
sync
sync

if ! mount ${node}2 mount_point0 &> /dev/null; then
	echo  "Cannot mount ${node}2"
	exit 1
fi


rm -fr mount_point0/*
echo "copy [rootfs] to ${node}2"
tar -jxf ../image/rootfs.tar.bz2 -C mount_point0/ &> /dev/null
chown -R 0.0 mount_point0/*
sync
echo "解压文件系统到${node}2完成！"

if [ ! -e "mount_point0/lib/modules/" ];then
mkdir -p mount_point0/lib/modules/
fi


echo "正在解压模块到${node}2/lib/modules/ ，请稍候..."

rm -rf mount_point0/lib/modules/*

tar jxf ../image/modules.tar.bz2 -C mount_point0/lib/modules/
sync
echo "解压模块到${node}2/lib/modules/完成！"


for ((i=5;i>0;i--))
do
		printf "\r是否要烧录emmc?(default y)  [y/n] $i S"
		read  -t 1 -n1  -p ""  ans2

		case $ans2 in
				N | n)
						printf "\033[;32m\n不烧录emmc...\n\033[0m";
						sync;
						chown -R 0.0 mount_point0/*
						umount ${node}2
						rmdir mount_point0
						echo "mksd done"
						exit 0;;
				Y | y)
						echo -e "\n[Continue...]"
						break;;

				*)  
					esac
done

						echo -e "\n[Copying emmc tools...]"
						mkdir mount_point0/mk_emmc &> /dev/null
						mkdir mount_point0/mk_emmc/image
						mkdir mount_point0/mk_emmc/scripts
						cp -a mkemmc.sh mount_point0/mk_emmc/scripts/
						cp -a ../image/*.imx ../image/Image ../image/*.dtb ../image/*.tar.bz2   mount_point0/mk_emmc/image/
						sync
						echo "copy emmc tools done"

sync
sync
chown -R 0.0 mount_point0/*
umount ${node}2
rmdir mount_point0
sync
echo "mksd done"

