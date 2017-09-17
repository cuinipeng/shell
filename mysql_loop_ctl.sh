#!/bin/bash

remote_install_cmd="nohup /root/github/shell/mysql_loop.sh install > /var/log/mysql_loop.log 2>&1 &"
remote_uninstall_cmd="nohup /root/github/shell/mysql_loop.sh uninstall > /var/log/mysql_loop.log 2>&1 &"
echo ssh root@runningpercy-master "\"$remote_install_cmd\""
echo ssh root@runningpercy-master "\"$remote_uninstall_cmd\""

