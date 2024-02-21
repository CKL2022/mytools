#!/bin/bash

# 获取当前时间并格式化为 [D-h:m]
current_time=$(date "+[%a-%H:%M]")
#current_time=$(date "+[%Y-%m-%d %a %H:%M:%S]")

# 运行 lsusb 命令并将输出存储到变量 lsusb_output 中
lsusb_output=$(lsusb)

# 检查 lsusb_output 中是否包含 "0fe6:9900 Kontron"
if echo "$lsusb_output" | grep -q "0fe6:9900"; then
    # 如果存在匹配行，将匹配行附加到 lsusb.txt，并添加当前时间
    #echo "$current_time $lsusb_output" | grep "0fe6:9900 Kontron" >> /lsusb.txt
	echo "$lsusb_output" | grep "0fe6:9900" | sed "s/^/$current_time /" >> /lsusb.txt

    # 统计匹配行的数量，并添加到 lsusb.txt 的最后一行
    count=$(cat /lsusb.txt | grep -c "0fe6:9900")
    echo "$current_time 网卡连续存在 $count 次" >> /lsusb.txt
	sync
	sleep 40
    # 重启系统
    reboot
else
    # 如果不存在匹配行，将 "网卡IC不存在" 附加到 lsusb.txt，并添加当前时间
    echo "$current_time 网卡IC不存在,停止重启" >> /lsusb.txt
    echo "$======================================" >> /lsusb.txt
    echo -e "$lsusb_output" >> /lsusb.txt
	echo "$======================================" >> /lsusb.txt

fi

