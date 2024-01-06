#!/bin/bash

#定义函数
function install_esap() {
	printf "\033[1;42mprogress:[%-40s]%d%%\r\033[0m" "$1" "$2"
	$3 > /dev/null 2>&1
	check_install
}

#检查安装状况
function check_install() {
	if [ $? -ne 0 ]
	then
		echo -e "\033[31m安装失败，请检查服务器网络是否联通，或者是否安装过程中按下Ctrl+C终止本脚本。本脚本即将退出...... \033[0m" 
		exit 1
	fi
}

function setup_init() {
	export SYSTEM="none"
	export SYSTEM_ID=$(. /etc/os-release && echo "$ID")
}

function get_manager() {
	#获取服务器包管理器信息
	dnf --version > /dev/null 2>&1
		
	if [ $? -eq 0 ]
	then
		export SYSTEM="dnf"
		if [ ${SYSTEM_ID} = "centos" ] || [ ${SYSTEM_ID} = "fedora" ] || [ ${SYSTEM_ID} = "rhel" ]
		then
			export SYSTEM_ID=$(. /etc/os-release && echo "$ID")
		else
			export SYSTEM_ID="centos-fake"
		fi
	else
		apt --version > /dev/null 2>&1
		if [ $? -eq 0 ]
		then
			export SYSTEM_ID=$(. /etc/os-release && echo "$ID")
			export SYSTEM="apt"
		else
			echo -e "\033[31m不支持此系统，可能将在以后支持。本脚本即将退出...... \033[0m" && exit 127
		fi
	fi
	#获取服务器包管理器信息-结束
}

#检查服务器是否安装了Docker
function is_docker_on() {
	false
}

#用户Ctrl+C停止部署时输出
trap 'onCtrlC' INT
function onCtrlC () {
    echo -e '\033[31m用户停止安装，本脚本即将退出......\033[0m'
	exit 130
}

function main() {
	#Docker自动（手动）安装
	echo -e "\033[34m安装Docker中......\033[0m"
	sleep 1
	
	if [ ${SYSTEM} = "dnf" ]
	then
		install_esap "" "0" "sudo dnf makecache && sudo dnf install -y yum-utils device-mapper-persistent-data lvm2 'dnf-command(config-manager)'"
		if [ ${SYSTEM_ID} = "centos-fake"]
			then
				install_esap "#############" "33" "sudo dnf config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo"
				sed -i 's/$releasever/8/g' /etc/yum.repos.d/docker-ce.repo
			else
				install_esap "#############" "33" "sudo dnf config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/${SYSTEM_ID}/docker-ce.repo"
		fi
		install_esap "##########################" "66" "sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin"
	
		sudo systemctl enable --now docker > /dev/null 2>&1
		check_install
		printf "progress:[%-40s]%d%%\r" "########################################" "100"
		sleep 0.5
		export DI="y"
		echo -e "\n\033[33mDocker安装完成\033[0m"
	elif [ ${SYSTEM} = "apt" ]
	then
		install_esap "" "0" "sudo NEEDRESTART_MODE=a apt-get update"
		install_esap "###" "7" "sudo NEEDRESTART_MODE=a apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common"
		printf "progress:[%-40s]%d%%\r" "#################" "43"
		curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add - > /dev/null 2>&1
		check_install
		install_esap "#######################" "57" "sudo apt-key fingerprint 0EBFCD88"
		#TODO：ARCH设置
		sudo add-apt-repository -y "deb [arch=amd64] http://mirrors.aliyun.com/docker-ce/linux/${SYSTEM_ID}/ $(lsb_release -cs) stable" > /dev/null 2>&1
		check_install
	
		install_esap "############################" "71" "sudo NEEDRESTART_MODE=a apt-get update"
		install_esap "##################################" "86" "sudo NEEDRESTART_MODE=a apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin"
	
		sudo systemctl enable --now docker > /dev/null 2>&1
		check_install
		printf "progress:[%-40s]%d%%\r" "########################################" "100"
		sleep 0.2
		export DI="y"
		echo -e "\n\033[33mDocker安装完成\033[0m"
	fi
	#Docker自动安装-结束
	
	#Docker Compose自动安装
	echo -e "\033[34m安装Docker Compose中......\033[0m"
	sleep 1
	
	if [ ${SYSTEM} = "dnf" ]
	then
	
		install_esap "" "0" "sudo dnf makecache"
		install_esap "####################" "50" "sudo dnf install -y docker-compose-plugin"
		
		docker compose > /dev/null 2>&1
		check_install
		printf "progress:[%-40s]%d%%\r" "########################################" "100"
		sleep 0.2
		echo -e "\n\033[33mDocker Compose安装完成\033[0m"
	
	elif [ ${SYSTEM} = "apt" ]
	then
		install_esap "" "0" "sudo NEEDRESTART_MODE=a apt-get update"
		install_esap "####################" "50" "sudo NEEDRESTART_MODE=a apt-get install -y docker-compose-plugin"
	
		docker compose > /dev/null 2>&1
		check_install
		printf "progress:[%-40s]%d%%\r" "########################################" "100"
		sleep 0.5
		echo -e "\n\033[33mDocker Compose安装完成\033[0m"
	fi
	#Docker Compose自动安装-结束
}

setup_init
get_manager
main