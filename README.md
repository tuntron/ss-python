# ss-python
#### Shadowsocks for Windows 客户端下载：
###### https://github.com/shadowsocks/shadowsocks-windows/releases

#### Shadowsocks for Mac 客户端下载：
###### https://github.com/shadowsocks/ShadowsocksX-NG/releases


#### 使用方法：
##### 使用root用户登录，运行以下命令：
```sh
wget --no-check-certificate -O shadowsocks.sh https://raw.githubusercontent.com/tuntron/ss-python/master/shadowsocks.sh
chmod +x shadowsocks.sh
./shadowsocks.sh 2>&1 | tee shadowsocks.log
```
#### 安装完成后，脚本提示如下：
```sh
Congratulations, Shadowsocks-python server install completed!
Your Server IP        :your_server_ip
Your Server Port      :your_server_port
Your Password         :your_password
Your Encryption Method:your_encryption_method

Enjoy it!
```
#### 卸载方法：
#####使用root用户登录，运行以下命令：
```sh
./shadowsocks.sh uninstall
```
### 如果遇到这个报错：
###### [Error] libsodium install failed!
先执行
```sh
 yum install gcc
```
在执行脚本

# v2-安装
#### 使用方法：
##### 使用root用户登录，运行以下命令：
```sh
wget --no-check-certificate -O v2-install.sh https://raw.githubusercontent.com/tuntron/ss-python/master/v2-install.sh
chmod +x v2-install.sh
./v2-install.sh 2>&1 | tee v2-install.log
```

# v2-docker 安装
```sh
yum install docker
mkdir -p /etc/v2ray
cat > /etc/v2ray/config.json <<EOF
{
  "inbounds": [{
    "port": 9000,
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "11c2a696-0366-4524-b8f0-9a9c21512b02",
          "level": 1,
          "alterId": 64
        }
      ]
    }
  }],
  "outbounds": [{
    "protocol": "freedom",
    "settings": {}
  }]
}
EOF
docker run -d -p 9000:9000 --name v2ray --restart=always -v /etc/v2ray:/etc/v2ray docker.io/v2fly/v2fly-core
```
