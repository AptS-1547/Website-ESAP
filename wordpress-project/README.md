# Wordpress非官方安装脚本
**注意！此脚本暂未完成！**  
支持已安装Docker的Linux系统  
如果未安装Docker，此脚本也会尝试安装支持官方脚本不支持的部分系统（OpencloudOS，TencentOS等RHEL系Linux发行版，Debian部分发行版，不支持Fedora）  
依赖于Docker Compose  
已测试系统：
- [ ] OpencloudOS
- [ ] Ubuntu
- [ ] Debian
- [ ] TencentOS  

## 使用方法：  

使用Github官方源：
```shell
curl -fsSL https://raw.githubusercontent.com/AptS-1547/Website-ESAP/master/wordpress-project/wordpress-website.sh | bash
```  

使用The ESAP Project镜像源：
```shell
curl -fsSL https://ftp.esaps.top:8080/dockersh/wordpress-project/wordpress-website.sh | bash
```  

将此命令复制到Linux Shell中，即可自动安装Cloudreve