#!/bin/bash

#check arg number
if [ $# != 0 ];then
	echo "Usage: ./mkinand-linux.sh"
	exit
fi

# check the if root?
userid=`id -u`
if [ $userid -ne "0" ]; then
echo "you're not root?"
exit
fi

#check image file exist or not?
files=../image


if [ ! -f $files/*.imx ]; then
  echo "错误: $files/下找不到uboot"
  exit 1
fi

if [ ! -e $files/rootfs.tar.bz2 ]; then
  echo "错误: ../image/下找不到文件系统压缩包"
  exit 1
fi

if [ ! -e $files/Image ]; then
  echo "错误: ../image/下找不到Image"
  exit 1
fi

if [ ! -f $files/modules.tar.bz2 ]; then
  echo "错误: $files/下找不到modules"
  exit 1
fi


node=/dev/mmcblk2

if [ ! -e ${node} ]; then
echo "There is no "${node}" in you system"
exit
fi

echo "即将进行制作eMMC系统启动卡，大约花费几分钟时间,请耐心等待!"
echo "************************************************************"
echo "*         注意：这将会清除$node所有的数据                  *"
echo "*         注意：请确认$node为emmc节点                      *"
echo "*         烧写eMMC前，请备份好重要的数据                   *"
echo "*             请按<Enter>确认继续                          *"
echo "************************************************************"
read enter

#分区前要卸载
for i in `ls -1 ${node}p?`; do
 echo "卸载 device '$i'"
 umount $i 2>/dev/null
done

sync

dd if=/dev/zero of=${node} bs=512 count=2 conv=fsync &> /dev/null;sync

cat << END | fdisk -H 255 -S 63 $node
n
p
1
10592
+32M
n
p
2
75776

t
1
c
a
1
w
END
sync
sleep 1
sync

#上面分区后系统会自动挂载，所以这里再一次卸载
for i in `ls -1 ${node}p?`; do
 echo "卸载 device '$i'"
 umount $i 2>/dev/null
done

echo "partitionfile done"
# format filesystem
mkfs.vfat -F 32 -n boot ${node}p1 &> /dev/null
mkfs.ext4 -F -L rootfs ${node}p2 &> /dev/null
sync

#烧写u-boot.imx到emmc boot0分区
echo "正在烧写 Uboot 到$node"
#烧写前，先使能mmcblk1boot0
echo 0 > /sys/block/mmcblk2boot0/force_ro
uboot=u-boot.imx
dd if=$files/$uboot of=${node}boot0 bs=1024 seek=33 conv=fsync

echo 1 > /sys/block/mmcblk2boot0/force_ro
sync

#烧写内核与设备树到 emmc mmcblk2p1
echo "正在准备复制..."
echo "正在复制设备树与内核到${node}p1，请稍候..."
mkdir -p ./mount0
mount ${node}p1 ./mount0
cp -r $files/*.dtb ./mount0
cp -r $files/Image ./mount0
chown -R 0.0 mount0
sync
echo "复制设备树与内核到${node}p1完成！"
echo "卸载${node}p1"
umount ./mount0
rm -rf ./mount0
sync


#挂载文件系统分区
mkdir ./mount1
mount ${node}p2 ./mount1

#解压文件系统到 emmc mmcblk1p2
echo "正在解压文件系统到${node}p2 ，请稍候..."
rootfs=$files/rootfs.tar.bz2
tar jxf $rootfs -C ./mount1
chown -R 0.0 mount1
sync
echo "解压文件系统到${node}p2完成！"

#判断是否存在这个目录，如果不存在就为文件系统创建一个modules目录
if [ ! -e "./mount1/lib/modules/" ];then
mkdir -p ./mount1/lib/modules
fi

echo "正在解压模块到${node}p2/lib/modules/，请稍候..."
rm -rf ./mount1/lib/modules/*

modules=$files/modules.tar.bz2
tar jxf $modules -C ./mount1/lib/modules/ &> /dev/null
chown -R 0.0 mount1/lib/*
sync
echo "解压模块到${node}p2/lib/modules/完成！"

echo "卸载${node}p2"
umount ./mount1
rm -rf ./mount1

#使能启动分区 /dev/mmcblk2
mmc bootpart enable 1 1 ${node}
sync
echo "eMMC启动系统烧写完成！"

