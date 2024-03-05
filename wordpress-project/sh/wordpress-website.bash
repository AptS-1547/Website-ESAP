#!/bin/bash

#定义函数

#用户Ctrl+C停止部署时输出
trap 'onCtrlC' INT
#TODO：Ctrlc退出脚本重写
function onCtrlC () {
	sudo rm -rf /var/docker_file/compose_file/wordpress/ > /dev/null 2>&1
	sudo rm -rf /var/docker_file/logs/nginx_website/ > /dev/null 2>&1
	sudo rm -rf /var/docker_file/logs/mariadb_website/ > /dev/null 2>&1
	sudo rm -rf /var/docker_file/logs/php_website/ > /dev/null 2>&1
	sudo rm -rf /var/docker_file/container/nginx_website/config/ > /dev/null 2>&1
	sudo rm -rf /var/docker_file/container/nginx_website/website_file/ > /dev/null 2>&1
	sudo rm -rf /var/docker_file/container/mariadb_website/init.d/ > /dev/null 2>&1
	sudo rm -rf /var/docker_file/container/mariadb_website/init.d/wordpress/ > /dev/null 2>&1
	sudo rm -rf /var/docker_file/container/mariadb_website/config/ > /dev/null 2>&1
	sudo rm -rf /var/docker_file/container/mariadb_website/database_backup/ > /dev/null 2>&1
	sudo rm -rf /var/docker_file/container/php_website/ > /dev/null 2>&1
	sudo rm -rf /var/docker_file/container/php_website/config/ > /dev/null 2>&1
	sudo rm -rf /var/docker_file/tmp/
	sudo docker stop nginx_website mariadb_website php-8.1.27-fpm-website
	sudo docker rm -f nginx_website mariadb_website php-8.1.27-fpm-website
    echo -e '\033[31m用户停止部署，本脚本即将退出......\033[0m'
	exit 130
}

function init_setup {
	export CCDI="n"
	export CCDCI="n"
	export UCDI="n"
	export UCDCI="n"
	export DI="n"
	export DCI="n"
	export UCWPI="n"
	export CCWPI="n"
	export WPI="n"
	export CCACME="n"
	export UCACME="n"
	export SYSTEM="none"
	
	export rootpasswd=""
	export wordpressdbpasswd=""
	export anorootpasswd=""
	export anowordpressdbpasswd=""
}

function main() {
	
	#验证服务器是否安装Docker
	#TODO：Docker安装
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
			case ${UCDI} in 
				[yY])
					export CCDI="y"
					break
					;;
				[nN])
					export CCDI="n"
					break
					;;
				*)
					echo -e "\033[31m输入有误，请重新输入\033[0m"
					;;
			esac
		done
	fi
	#验证服务器是否安装Docker-结束
	
	#是否启动Wordpress应用部署
	sudo docker network ls | grep "website_server_for_public" > /dev/null
	if [ $? -eq 0 ]
	then
		tput clear
		echo "检测到服务器已使用本脚本部署（安装）Wordpress应用，自动跳过部署（安装）......" 
		export WPI="y"
		sleep 1
	else
		while true
		do
			echo -e -n "\033[33m监测到服务器未部署（安装）Wordpress应用，是否部署（安装）？[y/n] \033[0m"
			read -p "" UCWPI
			case ${UCWPI} in 
				[yY])
					export CCWPI="y"
					break
					;;
				[nN])
					export CCWPI="n"
					break
					;;
				*)
					echo -e "\033[31m输入有误，请重新输入\033[0m"
					;;
			esac
		done
	fi
	#是否启动Wordpress应用部署-结束
	
	#启动Wordpress应用部署
	if [ ${CCWPI} = "y" ] && [ ${WPI} = "n" ]
	then
		#创建网站项目文件夹
		echo "将在/var文件夹下创建网站文件夹......"
		echo "路径：/var/docker_file/"
		sleep 1
		sudo mkdir /var/docker_file/ > /dev/null 2>&1
		sudo mkdir /var/docker_file/website/ > /dev/null 2>&1
		sudo mkdir /var/docker_file/website/nginx_website/ > /dev/null 2>&1
		sudo mkdir /var/docker_file/website/nginx_website/config/ > /dev/null 2>&1
		sudo mkdir /var/docker_file/website/nginx_website/website_file/ > /dev/null 2>&1
		sudo mkdir /var/docker_file/website/mariadb_website/ > /dev/null 2>&1
		sudo mkdir /var/docker_file/website/mariadb_website/init.d/ > /dev/null 2>&1
		sudo mkdir /var/docker_file/website/mariadb_website/config/ > /dev/null 2>&1
		sudo mkdir /var/docker_file/website/mariadb_website/database_backup/ > /dev/null 2>&1
		sudo mkdir /var/docker_file/website/php_website/ > /dev/null 2>&1
		sudo mkdir /var/docker_file/website/php_website/config/ > /dev/null 2>&1
		sudo mkdir /var/docker_file/tmp/ > /dev/null 2>&1
		tput clear
		#创建网站项目文件夹-结束
		#下载Wordpress文件
		echo -e "下载Wordpress文件中……"
		sleep 1
		for inumber in 1 2 3 4 5
		do
			sudo wget --no-check-certificate -c https://cn.wordpress.org/wordpress-6.4.2-zh_CN.tar.gz -P /var/docker_file/tmp/
			if [ $? -eq 0 ]
			then
				echo "下载完成"
				sleep 1
				break
			elif [ $? -ne 0 ] && [ ${inumber} -eq 5 ]
			then
				echo -e "\033[31m第${inumber}次下载失败，终止下载，请检查网络连接再重新尝试。本脚本即将退出......\033[0m"
				exit 127
			elif [ $? -ne 0 ] && [ ${inumber} -ne 5 ]
			then
				echo -e "\033[31m第${inumber}次下载失败，尝试重新下载......\033[0m"
				sleep 1
				tput clear
			fi
		done
		#下载Wordpress文件-结束
		
		#解压Wordpress文件
		echo "开始解压文件"
		sleep 1
		sudo tar xzvf /var/docker_file/tmp/wordpress-6.4.2-zh_CN.tar.gz -C /var/docker_file/website/nginx_website/website_file/
		echo "Wordpress文件解压完成！"
		sleep 1
		#解压Wordpress文件-结束
	#启动Wordpress应用部署-结束
		
	#部署docker-compose.yml-wordpress
		#下载wp-config.php配置文件
		echo "下载Wordpress配置文件中……"
		sleep 1
		#下载docker-compose.yml
		sudo curl -sk https://raw.githubusercontent.com/AptS-1547/Website-ESAP/master/wordpress-project/config/docker-compose.yml >  /var/docker_file/website/docker-compose.yml
		#下载初始Nginx conf文件（包括nginx conf https）
		sudo curl -sk https://raw.githubusercontent.com/AptS-1547/Website-ESAP/master/wordpress-project/config/wordpress.conf > /var/docker_file/website/nginx_website/config/wordpress.conf
		sudo curl -sk https://raw.githubusercontent.com/AptS-1547/Website-ESAP/master/wordpress-project/config/wordpress-https.conf.disabled > /var/docker_file/website/nginx_website/config/wordpress-https.conf.disabled
		#下载初始SQL文件
		sudo curl -sk https://raw.githubusercontent.com/AptS-1547/Website-ESAP/master/wordpress-project/config/init.sql > /var/docker_file/website/mariadb_website/init.d/wordpress/init.sql
		sudo chmod -R 777 /var/docker_file/website/nginx_website/website_file/wordpress/
		echo -e "\033[33m下载完成！\033[0m"
		sleep 1
		tput clear
		#修改Nginx配置文件-获取信息
		while true
		do
			echo -e -n "\033[33m请输入你的域名（比如example.com，不用输入http或https）： \033[0m"
			read -p "" hostname
			while true
			do
				echo -e -n "\033[33m是否启用acme.sh来为域名申请Let's Encrypt HTTPS证书？[y/n] \033[0m"
				read -p "" UCACME
				case ${UCWPI} in 
					[yY])
						echo "将会启用acme.sh来获取Let's Encrypt HTTPS证书\n"
						export CCACME="y"
						break
						;;
					[nN])
						export CCACME="n"
						break
						;;
					*)
						echo -e "\033[31m输入有误，请重新输入\033[0m"
						;;
				esac
			done
			#检测DNS解析
			echo -e "正在检测\033[33m${hostname}\033[0m是否已经添加DNS解析……"
			ping -c 4 ${hostname} > /dev/null 2>&1
			case $? in
				0)
					echo "\033[33m${hostname}\033[0m的DNS A纪录已经添加\n"
					sleep 1
					break
					;;
				*)
					echo -e "\e[31m未找到${hostname}的DNS A纪录，请重新输入正确的域名或添加正确的DNS解析！\033[0m\n"
					sleep 1
					;;
			esac
		done
		#检测是否含有其他文本
		while true
		do
			echo -e -n "\033[33m请输入Wordpress网站文件最大上传大小（单位：MB，仅输入数字。如30）： \033[0m"
			read -p "" uploadmaxmium
			echo ${uploadmaxmium} | grep -E "^[0-9]+$" > /dev/null
			case $? in
				0)
					break
					;;
				*)
					echo "输入有误，请重新输入"
					;;
			esac
		done
		#修改Nginx配置文件-绑定域名
		sudo sed -i "s/domain_name/${hostname}/" /var/docker_file/website/nginx_website/config/conf.d/wordpress.conf
		sudo sed -i "s/domain_name/${hostname}/" /var/docker_file/website/nginx_website/config/conf.d/wordpress-https.conf.disabled
		#修改Nginx配置文件-上传文件限制
		sudo sed -i "s/uploadmaxmium/${uploadmaxmium}M/" /var/docker_file/website/nginx_website/config/conf.d/wordpress.conf
		sudo sed -i "s/uploadmaxmium/${uploadmaxmium}M/" /var/docker_file/website/nginx_website/config/conf.d/wordpress-https.conf.disabled
		#修改docker-compose.yml文件-获取信息
		while true
		do
			echo -e -n "\033[33m请输入即将设置的MariaDB Root用户（数据库超级管理员）密码（留空自动设置）： \033[0m"
			read -p "" -s rootpasswd
			echo ""
			if [[ ${rootpasswd} = "" ]]
			then
				export rootpasswd=$(tr -cd 'a-zA-Z0-9[]{}#%^*+=' < /dev/urandom | head -c30)
				echo -e "\033[31;42m你的数据库Root用户密码为：${rootpasswd}，请牢记此密码！\033[0m"
				break
			else
				echo -e -n "\033[33m请再次输入即将设置的MariaDB Root用户（数据库超级管理员）密码： \033[0m"
				read -p "" -s anorootpasswd
				if [[ ${rootpasswd} = ${anorootpasswd} ]]
				then
					echo -e "\033[32mMariaDB Root用户（数据库超级管理员）密码已设置！\033[0m"
					break
				else
					echo -e "\033[31m输入有误，请重新输入\033[0m"
					sleep 1
				fi
			fi
		done
		sleep 1
		echo " "
	
		while true
		do
			echo -e -n "\033[33m请输入即将设置的MariaDB Wordpress用户（Wordpress数据库用户）密码（留空自动设置）： \033[0m"
			read -p "" -s wordpressdbpasswd
			echo ""
			if [[ ${wordpressdbpasswd} = "" ]]
			then
				export wordpressdbpasswd=$(tr -cd 'a-zA-Z0-9[]{}#%^*+=' < /dev/urandom | head -c30)
				echo -e "\033[31;42m你的数据库Wordpress用户密码为：${wordpressdbpasswd}。\033[0m"
				break
			else
				echo -e -n "\033[33m请再次输入即将设置的MariaDB Wordpress用户（Wordpress数据库用户）密码： \033[0m"
				read -p "" -s anowordpressdbpasswd
				if [[ ${wordpressdbpasswd} = ${anowordpressdbpasswd} ]]
				then
					echo -e "\033[32mMariaDB Wordpress用户（Wordpress数据库用户）密码已设置！\033[0m"
					break
				else
					echo -e "\033[31m输入有误，请重新输入\033[0m"
					sleep 1
				fi
			fi
		done
		echo " "
		sleep 3
	
		echo -e "\033[33m我们正在设置Docker Compose和MariaDB数据库，请等待……（这可能需要较长时间）\033[0m"
		sleep 1
		#修改docker-compose.yml文件
		sudo sed -i "s/domain_name/${hostname}/" /var/docker_file/website/docker-compose.yml
		sudo sed -i "s/ROOT_PASSWD/${rootpasswd}/" /var/docker_file/website/docker-compose.yml
		#修改init.sql文件
		echo 'CREATE DATABASE IF NOT EXISTS wordpress;' >> /var/docker_file/website/mariadb_website/init.d/init.sql
		echo "CREATE USER 'wordpress'@'%' IDENTIFIED BY '${wordpressdbpasswd}';" >> /var/docker_file/website/mariadb_website/init.d/init.sql
		echo 'GRANT ALL PRIVILEGES ON wordpress.* TO "wordpress"@"%";' >> /var/docker_file/website/mariadb_website/init.d/init.sql
		#更改Wordpress配置文件
		sudo cp /var/docker_file/website/nginx_website/website_file/wordpress/wp-config-sample.php /var/docker_file/website/nginx_website/website_file/wordpress/wp-config.php
		sudo sed -i "s/password_here/${wordpressdbpasswd}/" /var/docker_file/website/nginx_website/website_file/wordpress/wp-config.php
		sudo sed -i "s/database_name_here/wordpress/" /var/docker_file/website/nginx_website/website_file/wordpress/wp-config.php
		sudo sed -i "s/username_here/wordpress/" /var/docker_file/website/nginx_website/website_file/wordpress/wp-config.php
		sudo sed -i "s/localhost/mariadb-website/" /var/docker_file/website/nginx_website/website_file/wordpress/wp-config.php
		sudo sed -i "51,58d" /var/docker_file/website/nginx_website/website_file/wordpress/wp-config.php
		sudo curl -sk https://api.wordpress.org/secret-key/1.1/salt/ > /var/docker_file/tmp/KEYS_AND_SALTS
		sudo sed -i "51 r /var/docker_file/tmp/KEYS_AND_SALTS" /var/docker_file/website/nginx_website/website_file/wordpress/wp-config.php
		#更改Wordpress配置文件-结束
		
		#启动Docker Compose部署
		sudo docker compose -f /var/docker_file/website/docker-compose.yml up -d
		#下载默认php.ini文件 && 修改php.ini配置文件-上传文件限制
		sudo curl -sk https://raw.githubusercontent.com/AptS-1547/Website-ESAP/master/wordpress-project/config/php.ini > /var/docker_file/website/php_website/config/php.ini
		sudo sed -i "s/uploadmaxmium/${uploadmaxmium}M/" /var/docker_file/website/php_website/config/php.ini
		#php-fpm插件安装
		sleep 1
		echo -e "\033[33m请设置接下来安装PHP扩展时使用的镜像源\033[0m"
		echo -e "\033[33m1. 使用Debian官方源（推荐服务器在国外时使用）\033[0m"
		echo -e "\033[33m2. 使用USTC Mirror（推荐服务器在国内时使用）\033[0m"
		while true
		do
			echo -e -n "\033[33m请输入相对应镜像源数字编号： \033[0m"
			read -p "" mirrornumber
			case ${mirrornumber} in 
				[1])
					break
					;;
				[2])
					sudo docker exec -it php-8.1.27-fpm-website sed -i 's/deb.debian.org/mirrors.ustc.edu.cn/g' /etc/apt/sources.list
					break
					;;
				*)
					echo -e "\033[31m输入有误，请重新输入\033[0m"
					;;
			esac
		done
		tput clear
		echo "正在安装PHP扩展依赖，请稍后……"
		sudo docker exec -it php-8.1.27-fpm-website apt update > /dev/null
		sudo docker exec -it php-8.1.27-fpm-website apt install -y wget libzip-dev libicu-dev zlib1g-dev libfreetype6-dev libjpeg62-turbo-dev libpng-dev libmagickwand-dev imagemagick libmagick++-dev > /dev/null
		echo "正在安装PHP mysqli扩展，请稍后……"
		sudo docker exec -it php-8.1.27-fpm-website docker-php-ext-install mysqli > /dev/null
		echo "正在安装PHP gd扩展，请稍后……"
		sudo docker exec -it php-8.1.27-fpm-website docker-php-ext-install gd > /dev/null
		echo "正在安装PHP exif扩展，请稍后……"
		sudo docker exec -it php-8.1.27-fpm-website docker-php-ext-install exif > /dev/null
		echo "正在安装PHP zip扩展，请稍后……"
		sudo docker exec -it php-8.1.27-fpm-website docker-php-ext-install zip > /dev/null
		echo "正在安装PHP intl扩展，请稍后……"
		sudo docker exec -it php-8.1.27-fpm-website docker-php-ext-install intl > /dev/null
		echo "正在安装PHP imagick扩展，请稍后……"
		sudo docker exec -it php-8.1.27-fpm-website bash -c "yes '' | pecl install imagick" > /dev/null
		sudo docker exec -it php-8.1.27-fpm-website docker-php-ext-install imagick > /dev/null
		sudo sed -i "s/;extension=imagick.so/extension=imagick.so/" /var/docker_file/website/php_website/config/php.ini
		#重启服务
		echo "正在重启docker服务，请稍后……"
		sleep 1
		sudo docker compose -f /var/docker_file/website/docker-compose.yml restart
		sudo rm -rf /var/docker_file/tmp/
		
		#TODO：acme.sh申请证书
		
	#部署docker-compose.yml-wordpress-结束
	
	elif [ ${CCWPI} = "n" ] && [ ${WPI} = "n" ]
	then
		echo -e "\033[31m终止部署（安装）Wordpress应用，本脚本即将退出...... \033[0m" && exit 0
	fi
	
	
	#结束
	echo -e "\033[33m请试着在浏览器里输入你的网址：${hostname} 来访问你的网站喵~ \033[0m"
	sleep 1
	echo -e "\033[36m无事可做（Nothing To Do.） \033[0m"
	sleep 1
	echo -e "\033[36m完成！（Complete!） \033[0m"
	#结束-结束
}
