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
tput clear
echo -e "\033[36m自动安装脚本"
echo -e "Author: AptS-1547"
echo -e "Description: 懒人化自动安装Wordpress脚本 \033[0m"
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

#是否启动Wordpress应用部署
sudo docker network ls | grep "wordpress_server_for_public" > /dev/null
if [ $? -eq 0 ]
then
	echo "检测到服务器已使用本脚本部署（安装）Wordpress应用，自动跳过部署（安装）......" 
	export WPI="y"
	sleep 1
else
	while true
	do
		echo -e -n "\033[33m监测到服务器未部署（安装）Wordpress应用，是否部署（安装）？[y/n] \033[0m"
		read -p "" UCWPI
		case $UCWPI in 
			[yY])
				export CCWPI="y"
				break
				;;
			[nN])
				export CCWPI="n"
				break
				;;
			*)
				echo "输入有误，请重新输入"
				;;
		esac
	done
fi
#是否启动Wordpress应用部署-结束

#启动Wordpress应用部署
if [ $CCWPI = "y" ] && [ $WPI = "n" ]
then
	#创建网站项目文件夹
	echo "将在/var文件夹下创建网站文件夹......"
	echo "路径：/var/docker_file/"
	sleep 1
	sudo mkdir /var/docker_file/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/container/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/compose_file/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/compose_file/wordpress/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/logs/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/logs/nginx_website/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/logs/mariadb_website/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/logs/php_website/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/container/nginx_website/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/container/nginx_website/config/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/container/nginx_website/website_file/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/container/mariadb_website/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/container/mariadb_website/init.d/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/container/mariadb_website/init.d/wordpress/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/container/mariadb_website/config/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/container/mariadb_website/database_backup/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/container/php_website/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/container/php_website/config/ > /dev/null 2>&1
	sudo mkdir /var/docker_file/tmp/ > /dev/null 2>&1
	tput clear
	#创建网站项目文件夹-结束
	#下载Wordpress文件
	echo -e "下载Wordpress文件中……"
	sleep 1
	for inumber in 1 2 3 4 5
	do
		sudo wget -c https://cn.wordpress.org/latest-zh_CN.tar.gz -P /var/docker_file/tmp/
		if [ $? -eq 0 ]
		then
			echo "下载完成"
			sleep 1
			break
		elif [ $? -ne 0 ] && [ $inumber -eq 5 ]
		then
			echo -e "\033[31m第$inumber次下载失败，终止下载，请检查网络连接再重新尝试。本脚本即将退出......\033[0m"
			exit 127
		elif [ $? -ne 0 ] && [ $inumber -ne 5 ]
		then
			echo -e "\033[31m第$inumber次下载失败，尝试重新下载......\033[0m"
			sleep 1
			tput clear
		fi
	done
	#下载Wordpress文件-结束
	
	#解压Wordpress文件
	echo "开始解压文件"
	sleep 1
	sudo tar xzvf /var/docker_file/tmp/latest-zh_CN.tar.gz -C /var/docker_file/container/nginx_website/website_file/
	echo "Wordpress文件解压完成！"
	sleep 1
	#解压Wordpress文件-结束
#启动Wordpress应用部署-结束
	
#部署docker-compose.yml-wordpress
	#下载wp-config.php配置文件
	echo "下载Wordpress配置文件中……"
	sudo wget -c https://ftp.esaps.top:8080/dockersh/wordpress-project/wp-config.php -P /var/docker_file/container/nginx_website/website_file/wordpress/ > /dev/null
	#下载docker-compose.yml
	sudo wget -c https://ftp.esaps.top:8080/dockersh/wordpress-project/docker-compose.yml -P /var/docker_file/compose_file/wordpress/ > /dev/null
	#下载初始Nginx conf文件（包括nginx conf https）
	sudo wget -c https://ftp.esaps.top:8080/dockersh/wordpress-project/wordpress.conf -P /var/docker_file/container/nginx_website/config/ > /dev/null
	sudo wget -c https://ftp.esaps.top:8080/dockersh/wordpress-project/wordpress-https.conf.disabled -P /var/docker_file/container/nginx_website/config/ > /dev/null
	#下载初始SQL文件
	sudo wget -c https://ftp.esaps.top:8080/dockersh/wordpress-project/init.sql -P /var/docker_file/container/mariadb_website/init.d/wordpress/ > /dev/null
	sudo chmod -R 777 /var/docker_file/container/nginx_website/website_file/wordpress/
	echo -e "\033[33m下载完成！\033[0m"
	sleep 1
	tput clear
	#修改Nginx配置文件-获取信息
	echo -e -n "\033[33m请输入你的域名（比如example.com，不用输入http或https）： \033[0m"
	read -p "" hostname
	echo -e -n "\033[33m请输入Wordpress网站文件最大上传大小（单位：MB，结尾请输入M。如30M）： \033[0m"
	read -p "" uploadmaxmium
	#修改Nginx配置文件-绑定域名
	sudo sed -i "s/domain_name/$hostname/" /var/docker_file/container/nginx_website/config/wordpress.conf
	sudo sed -i "s/domain_name/$hostname/" /var/docker_file/container/nginx_website/config/wordpress-https.conf.disabled
	#修改Nginx配置文件-上传文件限制
	sudo sed -i "s/uploadmaxmium/$uploadmaxmium/" /var/docker_file/container/nginx_website/config/wordpress.conf
	sudo sed -i "s/uploadmaxmium/$uploadmaxmium/" /var/docker_file/container/nginx_website/config/wordpress-https.conf.disabled
	#修改docker-compose.yml文件-获取信息
	echo -e -n "\033[33m请输入即将设置的MariaDB Root用户（数据库超级管理员）密码： \033[0m"
	read -p "" -s rootpasswd
	echo " "
	echo -e -n "\033[33m请输入即将设置的MariaDB Wordpress用户（Wordpress数据库用户）密码： \033[0m"
	read -p "" -s wordpressdbpasswd
	echo " "
	sleep 1
	tput clear
	echo -e "\033[33m我们正在设置数据库和php库，请等待……（这可能需要较长时间）\033[0m"
	sleep 1
	#修改docker-compose.yml文件
	sudo sed -i "s/domain_name/$hostname/" /var/docker_file/compose_file/wordpress/docker-compose.yml
	sudo sed -i "s/ROOT_PASSWD/$rootpasswd/" /var/docker_file/compose_file/wordpress/docker-compose.yml
	#修改init.sql文件
	sudo sed -i "s/WORDPRESS_PASSWD/$wordpressdbpasswd/" /var/docker_file/container/mariadb_website/init.d/wordpress/init.sql
	#更改Wordpress配置文件
	sudo sed -i "s/WORDPRESS_PASSWD/$wordpressdbpasswd/" /var/docker_file/container/nginx_website/website_file/wordpress/wp-config.php
	sudo curl https://api.wordpress.org/secret-key/1.1/salt/ > /var/docker_file/tmp/KEYS_AND_SALTS
	sudo sed -i "52 r /var/docker_file/tmp/KEYS_AND_SALTS" /var/docker_file/container/nginx_website/website_file/wordpress/wp-config.php
	#更改Wordpress配置文件-结束
	
	#启动Docker Compose部署
	sudo docker compose -f /var/docker_file/compose_file/wordpress/docker-compose.yml up -d
	#下载默认php.ini文件 && 修改php.ini配置文件-上传文件限制
	sudo wget -c https://ftp.esaps.top:8080/dockersh/wordpress-project/php.ini -P /var/docker_file/container/php_website/config/ > /dev/null
	sudo sed -i "s/uploadmaxmium/$uploadmaxmium/" /var/docker_file/container/php_website/config/php.ini
	#php-fpm插件安装
	sudo docker exec -it php-8.1.18-fpm-website apt update > /dev/null
	sudo docker exec -it php-8.1.18-fpm-website apt install -y libzip-dev libicu-dev zlib1g-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libmagickwand-dev > /dev/null
	sudo docker exec -it php-8.1.18-fpm-website docker-php-ext-install mysqli > /dev/null
	sudo docker exec -it php-8.1.18-fpm-website docker-php-ext-install gd > /dev/null
	sudo docker exec -it php-8.1.18-fpm-website docker-php-ext-install exif > /dev/null
	sudo docker exec -it php-8.1.18-fpm-website docker-php-ext-install zip > /dev/null
	sudo docker exec -it php-8.1.18-fpm-website docker-php-ext-install intl > /dev/null
	echo -e "\033[33m由于PHP Imagick扩展安装过程中需要人工提供Imagemagick安装前缀\033[0m"
	echo -e "\033[33m当出现：“please provide the prefix of imagemagick installation [autodetect] : ”时\033[0m"
	echo -e "\033[33m请你按下键盘上的“Enter”来继续安装，请勿输入其他内容\033[0m"
	echo -e "\033[33m将在10秒后继续安装……\033[0m"
	sleep 10
	sudo docker exec -it php-8.1.18-fpm-website pecl install imagick
	sudo docker exec -it php-8.1.18-fpm-website docker-php-ext-install imagick > /dev/null
	#重启服务
	sudo docker compose -f /var/docker_file/compose_file/wordpress/docker-compose.yml restart
	sudo rm -rf /var/docker_file/tmp/
#部署docker-compose.yml-wordpress-结束

elif [ $CCWPI = "n" ] && [ $WPI = "n" ]
then
	echo -e "\033[31m终止部署（安装）Wordpress应用，本脚本即将退出...... \033[0m" && exit 0
fi


#结束
echo -e "\033[33m请试着在浏览器里输入你的网址：$hostname 来访问你的网站喵~ \033[0m"
sleep 1
echo -e "\033[36m无事可做（Nothing To Do.） \033[0m"
sleep 1
echo -e "\033[36m完成！（Complete!） \033[0m"
#结束-结束

