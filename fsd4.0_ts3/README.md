# FSD4.0 连飞服务器非官方安装脚本
**注意！此脚本暂未完成！**  
自动安装FSD4.0 连飞服务器应用脚本，依赖于Docker Compose  
使用[kuroneko/fsd: Marty Bochane's FSD 2 (github.com)](https://github.com/kuroneko/fsd)  
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
sudo wget https://raw.githubusercontent.com/AptS-1547/Website-ESAP/master/fsd4.0_ts3/FSD4.0_Server-Installer.sh && sudo bash FSD4.0_Server-Installer.sh
```   

使用**The ESAP Project**镜像源：
```shell
sudo wget https://ftp.esaps.top:8080/dockersh/fsd4.0_ts3/FSD4.0_Server-Installer.sh && sudo bash FSD4.0_Server-Installer.sh
```   

将此命令复制到*Linux Shell*中，即可自动安装FSD4.0 连飞服务器
