# Docker非官方安装脚本
支持官方脚本不支持的部分系统（OpencloudOS，TencentOS等RHEL系Linux发行版，Debian部分发行版，不支持Fedora）  
已测试系统：
- [x] OpencloudOS
- [x] Ubuntu
- [x] Debian
- [ ] TencentOS   

## 使用方法：  

使用Github官方源：
```shell
curl -fsSL https://raw.githubusercontent.com/AptS-1547/Website-ESAP/master/install-docker/Docker-Installer.sh | bash
```

使用The ESAP Project镜像源：
```shell
curl -fsSL https://ftp.esaps.top:8080/dockersh/install-docker/Docker-Installer.sh | bash
```   

将此命令复制到Linux Shell中，即可自动安装Docker