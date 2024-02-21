#!/bin/bash
src=$1
dst=$2
src_len=0
dcnt=0
if [ $# -gt 2 ]
then
    echo "error: too many parameter."
    exit
fi

if [ $# -lt 2 ]
then
    echo "error: missing parameter."
    exit
fi

echo "src="$src
echo "dst="$dst

function get_access() {
    r=`stat -c %a $1`
    echo "$r"
}

function get_owner() {
    r=`ls -dl $1 | awk '{print $3}'`
    echo $r
}

function get_group() {
    r=`ls -dl $1 | awk '{print $4}'`
    echo $r
}

function do_compare() {
    if [ ! -e $dst$1 ]; then
        return
    fi
    s=$src$1
    d=$dst$1

    own_flag=0
    acc_flag=0
    group_flag=0

    sacc=$(get_access $s)
    dacc=$(get_access $d)
    if [ "$sacc"a != "$dacc"a ]; then
        echo "access $s: $sacc" >> ./diff_log.txt
        echo "access $d: $dacc" >> ./diff_log.txt
        echo "" >> ./diff_log.txt
        dcnt=$(expr ${dcnt} + 1)
        echo "diff spot:"$dcnt
        acc_flag=1
    fi

    sown=$(get_owner $s)
    down=$(get_owner $d)
    if [ "$sown"a != "$down"a ]; then
        echo "owner $s: $sown" >> ./diff_log.txt
        echo "owner $d: $down" >> ./diff_log.txt
        echo "" >> ./diff_log.txt
        dcnt=$(expr ${dcnt} + 1)
        echo "diff spot:"$dcnt
        own_flag=1
    fi

    sg=$(get_group $s)
    dg=$(get_group $d)
    if [ "$sg"a != "$dg"a ]; then
        echo "group $s: $sg" >> ./diff_log.txt
        echo "group $d: $dg" >> ./diff_log.txt
        echo "" >> ./diff_log.txt
        dcnt=$(expr ${dcnt} + 1)
        echo "diff spot:"$dcnt
        group_flag=1
    fi

    if [ $acc_flag == 1 ]; then
        echo "chmod $dacc $s"
        chmod $dacc $s
    fi
    if [ $own_flag == 1 -o $group_flag == 1 ]; then
        echo "chown $down:$dg $s"
        chown $down:$dg $s
    fi
}

function read_dir() {
    temp=`ls $1`
    for file in $temp
    do
        fs=$1"/"$file
        do_compare ${fs: src_len}
        if [ -d $1"/"$file ]; then
            read_dir $1"/"$file
        fi
    done
} 

touch ./diff_log.txt
echo "" > ./diff_log.txt

src_len=`expr length $src`
read_dir $src
