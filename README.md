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
wget --no-check-certificate -O go.sh https://raw.githubusercontent.com/tuntron/ss-python/master/go.sh
chmod +x go.sh
./go.sh 2>&1 | tee v2-install.log
```
