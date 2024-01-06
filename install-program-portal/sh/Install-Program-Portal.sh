#!/bin/bash

while true
do
	echo -e  "\033[33m接下来要安装什么呢喵~？ \033[0m"
	
	echo -e -n "\033[33m请输入数字编号喵~ （输入h获取帮助,输入n退出）： \033[0m"
	read -p "" choose
	case $choose in 
		[1])
			bash <(curl -fsL https://raw.githubusercontent.com/AptS-1547/Website-ESAP/master/install-docker/sh/Docker-Installer.sh)
			break
			;;
		[2])
			export CCWPI="y"
			break
			;;
		[3])
			export CCWPI="y"
			break
			;;
		[4])
			export CCWPI="y"
			break
			;;
		[hH])
			echo -e "\033[33m1.\033[32mDocker安装脚本\033[0m"
			echo -e "\033[33m2.\033[31mWordpress安装脚本\033[0m"
			echo -e "\033[33m3.\033[31mCloudreve安装脚本\033[0m"
			echo -e "\033[33m4.\033[31m不知道这是什么\033[0m"
			break
			;;
		[nN])
			echo -e "\033[31m终止部署（安装），本脚本即将退出喵...... \033[0m" && exit 0
			break
			;;
		*)
			echo "输入有误，请重新输入喵~"
			;;
	esac
done