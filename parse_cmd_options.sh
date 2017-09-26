#!/bin/bash

# "$*" 和 "$@"(加引号)并不同, "$*"将所有的参数解释成一个字符串, 而"$@"是一个参数数组.
#for i in "$*"; do
#    echo ${i}
#done
#for i in "$@"; do
#    echo ${i}
#done

# getopts/getopt的区别, getopt是个外部binary文件, 而getopts是shell builtin.
# getopts 不能处理长选项(--prefix=/home)
# type getopts
# 第一个冒号表示忽略错误, 字符后面的冒号表示该选项必须有自己的参数
# $OPTIND 总是存储原始$*中下一个要处理的元素位置
# getopts修改$OPTARG
echo $*
while getopts ":a:bc" opt
do
    case $opt in
        a)
            echo $OPTARG
            echo $OPTIND
            ;;
        b)
            echo $OPTIND
            ;;
        c)
            echo $OPTIND
            ;;
        ?)
            echo "Error"
            ;;
    esac
done

# echo $optind
# shift $(($optind - 1))

