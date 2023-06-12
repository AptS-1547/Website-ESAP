# Wordpress非官方安装脚本
**注意！此脚本暂未完成！**  
自动安装Wordpress应用脚本，依赖于Docker Compose  
支持已安装Docker的Linux系统  
如果未安装Docker，此脚本也会尝试安装支持官方脚本不支持的部分系统（OpencloudOS，TencentOS等RHEL系Linux发行版，Debian部分发行版，不支持Fedora）  
已测试系统：
- [ ] OpencloudOS
- [ ] Ubuntu
- [ ] Debian
- [ ] TencentOS  

## 使用方法：  

使用**Github**官方源：
```shell
sudo wget https://raw.githubusercontent.com/AptS-1547/Website-ESAP/master/wordpress-project/wordpress-website.sh
sudo bash wordpress-website.sh
```  

使用**The ESAP Project**镜像源：
```shell
sudo wget https://ftp.esaps.top:8080/dockersh/wordpress-project/wordpress-website.sh
sudo bash wordpress-website.sh
```  

将此命令复制到*Linux Shell*中，即可自动安装Cloudreve