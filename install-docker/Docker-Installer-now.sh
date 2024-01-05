#!/bin/bash

#定义函数
#TODO：写一个通用的apt和dnf安装函数
function install_esap() {
	tput cup 1 0
	echo $1
	$2
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
    echo -e '\033[31m用户停止安装Docker，本脚本即将退出......\033[0m'
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
			apt --version > /dev/null 2>&1
			if [ $? -eq 0 ]
			then 
				export SYSTEM="apt"
			else
				echo -e "\033[31m不支持此系统，可能将在以后支持。本脚本即将退出...... \033[0m" && exit 127
			fi
		fi
		#获取服务器包管理器信息-结束
}

function main() {
	
	tput clear
	echo "安装Docker中......"
	sleep 1
	
	#Docker自动安装
	if [ ${SYSTEM} = "dnf" ]
	then
		install_esap "[------------------------------] 0%" "sudo dnf makecache > /dev/null"
		install_esap "[------------------------------] 0%" "sudo dnf install -y yum-utils device-mapper-persistent-data lvm2 > /dev/null"
		install_esap "[==========--------------------] 33%" "sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo > /dev/null"
		install_esap "[====================----------] 66%" "sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin > /dev/null"
		docker -v > /dev/null 2>&1
		check_install
		sudo systemctl enable --now docker
		tput clear
		echo "安装Docker中......"
		echo -n "[==============================] 100%"
		sleep 0.5
		export DI="y"
		echo "......Docker安装完成"
	
	elif [ ${SYSTEM} = "apt" ]
	then
		install_esap "[------------------------------] 0%" "sudo NEEDRESTART_MODE=a apt-get update > /dev/null"
		install_esap "[==----------------------------] 7%" "sudo NEEDRESTART_MODE=a apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common > /dev/null"
		install_esap "[========----------------------] 28%" "curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add - > /dev/null"
		install_esap "[=============-----------------] 43%" "sudo apt-key fingerprint 0EBFCD88 > /dev/null"
		
		echo "[=================-------------] 57%"
		grep "ubuntu" /etc/os-release
		if [ $? -eq	0 ]
		then
			sudo add-apt-repository -y "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/ $(lsb_release -cs) stable" > /dev/null	
		else
			sudo add-apt-repository -y "deb [arch=amd64] https://mirrors.ustc.edu.cn/docker-ce/linux/debian/ $(lsb_release -cs) stable" > /dev/null
		fi
		check_install
		tput cup 1 0
		
		install_esap "[=====================---------] 71%" "sudo NEEDRESTART_MODE=a apt-get update > /dev/null"
		install_esap "[==========================----] 86%" "sudo NEEDRESTART_MODE=a apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin > /dev/null"

		docker -v > /dev/null 2>&1
		check_install
		sudo systemctl enable --now docker
		tput clear
		echo "安装Docker中......"
		echo -n "[==============================] 100%"
		sleep 0.5
		export DI="y"
		echo "......Docker安装完成"
	
	elif [ ${CCDI} = "n" ] && [ ${DI} = "n" ]
	then
		echo -e "\033[31m终止安装Docker，本脚本即将退出...... \033[0m" && exit 0
	
	fi
	#Docker自动安装-结束
	
	#Docker Compose自动安装
	if [ ${SYSTEM} = "dnf" ]
	then
		tput clear
		echo "安装Docker Compose中......"
		sleep 1
	
		tput cup 1 0
		echo "[------------------------------] 0%"
		sudo dnf makecache > /dev/null
		check_install
		tput cup 1 0
		
		tput cup 1 0
		echo "[===============---------------] 50%"
		sudo dnf install -y docker-compose-plugin > /dev/null
		check_install
		tput cup 1 0
		
		docker -v > /dev/null 2>&1
		check_install
		
		tput clear
		echo -n "[==============================] 100%"
		
		sleep 0.5
		echo "......Docker Compose安装完成"
	
	elif [ ${SYSTEM} = "apt" ]
	then
		tput clear
		echo "安装Docker Compose中......"
		sleep 1
		
		tput cup 1 0
		echo "[------------------------------] 0%"
		sudo apt-get update > /dev/null
		check_install
		tput cup 1 0
		
		tput cup 1 0
		echo "[===============---------------] 50%"
		sudo apt-get install -y docker-compose-plugin > /dev/null
		check_install
		tput cup 1 0
		
		docker compose > /dev/null 2>&1
		check_install
		
		tput clear
		echo -n "[==============================] 100%"
		
		sleep 0.5
		echo "......Docker Compose安装完成"
		sleep 1
	
	elif [ ${CCDI} = "n" ] && [ ${DI} = "n" ]
	then
		echo -e "\033[31m终止安装Docker Compose，本脚本即将退出...... \033[0m" && exit 0
	
	fi
	#Docker Compose自动安装-结束
}