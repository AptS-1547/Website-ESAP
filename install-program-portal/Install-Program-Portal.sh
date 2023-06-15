#!/bin/bash
tput clear
echo -e "\033[36m自动安装脚本"
echo -e "Author: AptS-1547"
echo -e "Description: Website-ESAP项目 Docker Compose自动安装脚本 \033[0m"

while true
do
	echo -e  "\033[33m接下来要安装什么呢喵~？ \033[0m"
	
	echo -e -n "\033[33m请输入数字编号喵~ ： \033[0m"
	read -p "" choose
	case $choose in 
		[1])
			export CCWPI="y"
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
		[5])
			export CCWPI="y"
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