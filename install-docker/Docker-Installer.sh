#!/bin/bash

#定义函数
function check_install() {
	if [ $? -ne 0 ]
	then
		tput clear
		echo -e "\033[31m安装失败，请检查服务器网络是否联通，或者是否安装过程中按下Ctrl+C终止本脚本。本脚本即将退出...... \033[0m" 
		exit 127
	fi
}

#用户Ctrl+C停止部署时输出
trap 'onCtrlC' INT
function onCtrlC () {
    echo -e '\033[31m用户停止部署，本脚本即将退出......\033[0m'
	exit 130
}

export CCDI="n"
export CCDCI="n"
export UCDI="n"
export UCDCI="n"
export DI="n"
export DCI="n"
export UCWPI="n"
export CCWPI="n"
export WPI="n"
SYSTEM="none"

#版权信息
echo -e "\033[36m自动安装脚本"
echo -e "Author: AptS-1547"
echo -e "Description: 懒人化自动安装Docker脚本（支持OpencloudOS等官方不支持系统，不支持Fedora） \033[0m"
#版权信息-结束

sleep 0.5

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
		echo -e "\033[31m不支持此系统，可能将在以后支持。本脚本即将退出...... \033[0m" && exit 0
	fi
fi

sleep 0.5
#获取服务器包管理器信息-结束

#验证服务器是否安装Docker
docker -v > /dev/null 2>&1

if [ $? -eq 0 ]
then
	echo "检测到服务器已安装Docker 自动跳过Docker安装......" 
	export DI="y"
	sleep 1
else
	while true
	do
		echo -e -n "\033[33m监测到服务器未安装Docker，是否安装？[y/n] \033[0m"
		read -p "" UCDI
		case $UCDI in 
			[yY])
				export CCDI="y"
				break
				;;
			[nN])
				export CCDI="n"
				break
				;;
			*)
				echo "输入有误，请重新输入"
				;;
		esac
	done
fi
#验证服务器是否安装Docker-结束

#Docker自动安装
if [ $CCDI = "y" ] && [ $DI = "n" ] && [ $SYSTEM = "dnf" ]
then
	tput clear
	echo "安装Docker中......"
	sleep 1
	
	tput cup 1 0
	echo "[------------------------------] 0%"
	sudo dnf makecache > /dev/null
	check_install
	tput cup 1 0
	
	tput cup 1 0
	echo "[------------------------------] 0%"
	sudo dnf install -y yum-utils device-mapper-persistent-data lvm2 > /dev/null
	check_install
	tput cup 1 0
	
	echo "[==========--------------------] 33%"
	sudo yum-config-manager --add-repo http://mirrors.aliyun.com/docker-ce/linux/centos/docker-ce.repo > /dev/null
	check_install
	tput cup 1 0
	
	echo "[====================----------] 66%"
	sudo dnf install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin > /dev/null
	check_install
	tput cup 1 0
	
	docker -v > /dev/null 2>&1
	check_install
	
	sudo systemctl enable docker
	sudo systemctl start docker
	
	tput clear
	echo -n "[==============================] 100%"
	
	sleep 0.5
	export DI="y"
	echo "......Docker安装完成"

elif [ $CCDI = "y" ] && [ $DI = "n" ] && [ $SYSTEM = "apt" ]
then
	tput clear
	echo "安装Docker中......"
	sleep 1
	
	tput cup 1 0
	echo "[------------------------------] 0%"
	sudo apt-get update > /dev/null
	check_install
	tput cup 1 0
	
	echo "[====--------------------------] 14%"
	sudo apt-get install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common > /dev/null
	check_install
	tput cup 1 0
	
	echo "[========----------------------] 28%"
	curl -fsSL https://mirrors.ustc.edu.cn/docker-ce/linux/ubuntu/gpg | sudo apt-key add - > /dev/null
	check_install
	tput cup 1 0
	
	echo "[=============-----------------] 43%"
	sudo apt-key fingerprint 0EBFCD88 > /dev/null
	check_install
	tput cup 1 0
	
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
	
	echo "[=====================---------] 71%"
	sudo apt-get update > /dev/null
	check_install
	tput cup 1 0
	
	echo "[==========================----] 86%"
	sudo apt-get -y install docker-ce docker-ce-cli containerd.io docker-compose-plugin > /dev/null
	check_install
	tput cup 1 0
	
	docker -v > /dev/null 2>&1
	check_install
	
	sudo systemctl enable docker
	check_install
	sudo systemctl start docker
	check_install
	
	tput clear
	echo "安装Docker中......"
	echo -n "[==============================] 100%"
	
	sleep 0.5
	export DI="y"
	echo "......Docker安装完成"

elif [ $CCDI = "n" ] && [ $DI = "n" ]
then
	echo -e "\033[31m终止安装Docker，本脚本即将退出...... \033[0m" && exit 0

fi
#Docker自动安装-结束



#验证服务器是否安装Docker Compose
docker compose > /dev/null 2>&1

if [ $? -eq 0 ]
then
	echo "检测到服务器已安装Docker Compose 自动跳过Docker Compose安装......" 
	export DCI="y"
	sleep 1
else
	while true
	do
		echo -e -n "\033[33m监测到服务器未安装Docker Compose，是否安装？[y/n] \033[0m"
		read -p "" UCDCI
		case $UCDCI in 
			[yY])
				export CCDCI="y"
				break
				;;
			[nN])
				export CCDCI="n"
				break
				;;
			*)
				echo "输入有误，请重新输入"
				;;
		esac
	done
fi
#验证服务器是否安装Docker Compose结束

#Docker Compose自动安装
if [ $CCDCI = "y" ] && [ $DI = "y" ] && [ $DCI = "n" ] && [ $SYSTEM = "dnf" ]
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

elif [ $CCDCI = "y" ] && [ $DI = "y" ] && [ $DCI = "n" ] && [ $SYSTEM = "apt" ]
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

elif [ $CCDI = "n" ] && [ $DI = "n" ]
then
	echo -e "\033[31m终止安装Docker Compose，本脚本即将退出...... \033[0m" && exit 0

fi
#Docker Compose自动安装-结束

#结束
echo -e "\033[36m无事可做（Nothing To Do.） \033[0m"
sleep 1
echo -e "\033[36m完成！（Complete!） \033[0m"
#结束-结束