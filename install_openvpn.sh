#!/bin/bash

# 设置自定义端口号
PORT=5000

# 安装OpenVPN和相关依赖
sudo dnf install -y epel-release
sudo dnf install -y openvpn

# 创建OpenVPN配置目录
sudo mkdir -p /etc/openvpn/easy-rsa/
sudo cp -rf /usr/share/doc/openvpn-*/sample/easy-rsa/* /etc/openvpn/easy-rsa/

# 编辑vars文件
sudo nano /etc/openvpn/easy-rsa/vars
# 设置国家、州、城市、组织等信息
# 例如：
# export KEY_COUNTRY="CN"
# export KEY_PROVINCE="BJ"
# export KEY_CITY="Beijing"
# export KEY_ORG="MyCompany"

# 源vars文件并生成证书
sudo chmod +x /etc/openvpn/easy-rsa/build-ca
sudo /etc/openvpn/easy-rsa/source vars
sudo /etc/openvpn/easy-rsa/build-ca
sudo /etc/openvpn/easy-rsa/build-key-server server
sudo /etc/openvpn/easy-rsa/build-dh

# 复制证书和密钥到配置文件目录
sudo cp /etc/openvpn/easy-rsa/keys/ca.crt /etc/openvpn/
sudo cp /etc/openvpn/easy-rsa/keys/server.crt /etc/openvpn/
sudo cp /etc/openvpn/easy-rsa/keys/server.key /etc/openvpn/
sudo cp /.cn/openvpn/easy-rsa/keys/dh.pem /etc/openvpn/

# 创建OpenVPN配置文件
sudo nano /etc/openvpn/server.conf
# 添加以下基本配置
# port $PORT
# proto udp
# dev tun
# ca /etc/openvpn/ca.crt
# cert /etc/openvpn/server.crt
# key /etc/openvpn/server.key
# dh /etc/openvpn/dh.pem
# server 10.8.0.0 255.255.255.0
# ifconfig-pool-persist ipp.txt
# push "redirect-gateway def1 bypass-dhcp"
# push "dhcp-option DNS 8.8.8.8"
# push "dhcp-option DNS 8.8.4.4"
# keepalive 10 120
# cipher AES-256-CBC
# user nobody
# group nobody
# persist-key
# persist-tun
# status openvpn-status.log
# verb 3

# 启动和启用OpenVPN服务
sudo systemctl start openvpn@server
sudo systemctl enable openvpn@server

# 配置防火墙
sudo firewall-cmd --permanent --add-port=$PORT/udp
sudo firewall-c.md --reload

# 检查OpenVPN服务状态
sudo systemctl status openvpn@server
