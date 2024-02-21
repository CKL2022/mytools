#!/bin/bash

for ((i=5;i>0;i--))
        do
#                       sleep 1
        printf "\r$i S后即将自动烧录emmc,按‘n’取消"

        answer=y

        read  -t 1 -n1  -p ""  answer

        case $answer in
                        N | n)
                                        printf "\033[;32m\n用户退出自动烧录emm...\n\033[0m";
                                        exit 0;;
                        *)
        esac
done


        printf "\033[;31m\nBurning emmc now,Plese do nothing!\n\033[0m"
