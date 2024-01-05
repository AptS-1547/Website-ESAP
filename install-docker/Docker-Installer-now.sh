#!/bin/bash

#定义函数
function install_esap() {
	tput cup 1 0
	printf "progress:[%-40s]%d%%\r" "$1" "$2"
	$3 > /dev/null 2>&1
	check_install
	tput cup 1 0
}

#检查安装状况
function check_install() {
	if [ $? -ne 0 ]
	then
		echo -e "\033[31m安装失败，请检查服务器网络是否联通，或者是否安装过程中按下Ctrl+C终止本脚本。本脚本即将退出...... \033[0m" 
		exit 1
	fi
}

#用户Ctrl+C停止部署时输出
trap 'onCtrlC' INT
function onCtrlC () {
    echo -e '\033[31m用户停止安装，本脚本即将退出......\033[0m'
	exit 130
}

function setup_init() {
	export SYSTEM="none"
}

function get_manager() {
	#获取服务器包管理器信息
	dnf --version > /dev/null 2>&1
		
	if [ $? -eq 0 ]
	then export SYSTEM="dnf"
	else
		apt --version
		if [ $? -eq 0 ]
		then 
			export SYSTEM="apt"
		else
			echo -e "\033[31m不支持此系统，可能将在以后支持。本脚本即将退出...... \033[0m" && exit 127
		fi
	fi
		#获取服务器包管理器信息-结束
}

setup_init
get_manager


#Docker自动（手动）安装
tput clear
echo "安装Docker中......"
sleep 1

if [ ${SYSTEM} = "dnf" ]
then
	install_esap "" "0" "sudo dnf makecache && sudo dnf install -y yum-utils device-mapper-persistent-data lvm2"
	install_esap "#############" "33" "sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo"
	install_esap "##########################" "66" "sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin"

	sudo systemctl enable --now docker > /dev/null	2>&1
	check_install
	printf "progress:[%-40s]%d%%\r" "########################################" "100"
	sleep 0.5
	export DI="y"
	echo "......Docker安装完成"
elif [ ${SYSTEM} = "apt" ]
then
	install_esap "" "0" "sudo NEEDRESTART_MODE=a apt-get update"
	install_esap "###" "7" "sudo NEEDRESTART_MODE=a apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common"
	printf "progress:[%-40s]%d%%\r" "#################" "43"
	
	grep "ubuntu" /etc/os-release
	if [ $? -eq	0 ]
	then
		curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add - > /dev/null 2>&1
		check_install
		install_esap "#######################" "57" "sudo apt-key fingerprint 0EBFCD88"
		sudo add-apt-repository -y "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/ $(lsb_release -cs) stable" > /dev/null	2>&1
	else
		curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/debian/gpg | sudo apt-key add - > /dev/null 2>&1
		check_install
		install_esap "#######################" "57" "sudo apt-key fingerprint 0EBFCD88"
		sudo add-apt-repository -y "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/debian/ $(lsb_release -cs) stable" > /dev/null 2>&1
	fi
	check_install

	install_esap "############################" "71" "sudo NEEDRESTART_MODE=a apt-get update"
	install_esap "##################################" "86" "sudo NEEDRESTART_MODE=a apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin"

	sudo systemctl enable --now docker > /dev/null 2>&1
	check_install
	printf "progress:[%-40s]%d%%\r" "########################################" "100"
	sleep 0.5
	export DI="y"
	echo "......Docker安装完成"
fi
#Docker自动安装-结束

#Docker Compose自动安装
tput clear
echo "安装Docker Compose中......"
sleep 1

if [ ${SYSTEM} = "dnf" ]
then

	install_esap "" "0" "sudo dnf makecache"
	install_esap "####################" "50" "sudo dnf install -y docker-compose-plugin"
	
	docker compose > /dev/null 2>&1
	check_install
	printf "progress:[%-40s]%d%%\r" "########################################" "100"
	sleep 0.5
	echo "......Docker Compose安装完成"

elif [ ${SYSTEM} = "apt" ]
then
	install_esap "" "0" "sudo NEEDRESTART_MODE=a apt-get update"
	install_esap "####################" "50" "sudo NEEDRESTART_MODE=a apt-get install -y docker-compose-plugin"

	docker compose > /dev/null 2>&1
	check_install
	printf "progress:[%-40s]%d%%\r" "########################################" "100"
	sleep 0.5
	echo "......Docker Compose安装完成"
#Docker Compose自动安装-结束
