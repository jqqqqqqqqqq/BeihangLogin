#!/bin/bash
ping -c 1 www.baidu.com > /dev/null 2>&1
if [ $? -eq 0 ];then
    true
else
    ./login-v2.sh login
fi
