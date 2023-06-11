# Cloudreve非官方安装脚本
**注意！此脚本暂未完成！**  
自动安装Cloudreve应用脚本，依赖于Docker Compose  
支持已安装Docker的Linux系统  
如果未安装Docker，此脚本也会尝试安装，支持官方脚本不支持的部分系统（OpencloudOS，TencentOS等RHEL系Linux发行版，Debian部分发行版，不支持Fedora）  
已测试系统：
- [ ] OpencloudOS
- [ ] Ubuntu
- [ ] Debian
- [ ] TencentOS   

## 使用方法：  

使用**Github**官方源：
```shell
sudo curl -fsSL https://raw.githubusercontent.com/AptS-1547/Website-ESAP/master/cloudreve-project/Cloudreve-Installer.sh | bash
```

使用**The ESAP Project**镜像源：
```shell
sudo curl -fsSL https://ftp.esaps.top:8080/dockersh/cloudreve-project/Cloudreve-Installer.sh | bash
```   

将此命令复制到*Linux Shell*中，即可自动安装Cloudreve