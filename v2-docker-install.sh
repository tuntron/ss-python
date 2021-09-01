#!/bin/bash

red='\e[91m'
green='\e[92m'
yellow='\e[93m'
magenta='\e[95m'
cyan='\e[96m'
none='\e[0m'
_red() { echo -e ${red}$*${none}; }
_green() { echo -e ${green}$*${none}; }
_yellow() { echo -e ${yellow}$*${none}; }
_magenta() { echo -e ${magenta}$*${none}; }
_cyan() { echo -e ${cyan}$*${none}; }

# Root
[[ $(id -u) != 0 ]] && echo -e "\n 哎呀……请使用 ${red}root ${none}用户运行 ${yellow}~(^_^) ${none}\n" && exit 1

cmd="apt-get"

sys_bit=$(uname -m)

# 笨笨的检测方法
if [[ $(command -v apt-get) || $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then

	if [[ $(command -v yum) ]]; then

		cmd="yum"

	fi

else

	echo -e " 
	哈哈……这个 ${red}辣鸡脚本${none} 不支持你的系统。 ${yellow}(-_-) ${none}

	备注: 仅支持 Ubuntu 16+ / Debian 8+ / CentOS 7+ 系统
	" && exit 1

fi

uuid=$(cat /proc/sys/kernel/random/uuid)
old_id="e55c8d17-2cf3-b21a-bcf1-eeacb011ed79"
v2ray_server_config="/etc/v2ray/config.json"
systemd=true
# _test=true

transport=(
	TCP
	TCP_HTTP
	WebSocket
)
v2ray_config() {
	# clear
	echo
	while :; do
		echo -e "请选择 "$yellow"V2Ray"$none" 传输协议 [${magenta}1-${#transport[*]}$none]"
		echo
		for ((i = 1; i <= ${#transport[*]}; i++)); do
			Stream="${transport[$i - 1]}"
			if [[ "$i" -le 9 ]]; then
				# echo
				echo -e "$yellow  $i. $none${Stream}"
			else
				# echo
				echo -e "$yellow $i. $none${Stream}"
			fi
		done
		echo
		echo "备注1: 含有 [dynamicPort] 的即启用动态端口.."
		echo "备注2: [utp | srtp | wechat-video | dtls | wireguard] 分别伪装成 [BT下载 | 视频通话 | 微信视频通话 | DTLS 1.2 数据包 | WireGuard 数据包]"
		echo
		read -p "$(echo -e "(默认协议: ${cyan}TCP$none)"):" v2ray_transport
		[ -z "$v2ray_transport" ] && v2ray_transport=1
		case $v2ray_transport in
		[1-9] | [1-2][0-9] | 3[0-2])
			echo
			echo
			echo -e "$yellow V2Ray 传输协议 = $cyan${transport[$v2ray_transport - 1]}$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		*)
			error
			;;
		esac
	done
	v2ray_port_config
}
v2ray_port_config() {
		local random=$(shuf -i20001-65535 -n1)
		while :; do
			echo -e "请输入 "$yellow"V2Ray"$none" 端口 ["$magenta"1-65535"$none"]"
			read -p "$(echo -e "(默认端口: ${cyan}${random}$none):")" v2ray_port
			[ -z "$v2ray_port" ] && v2ray_port=$random
			case $v2ray_port in
			[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
				echo
				echo
				echo -e "$yellow V2Ray 端口 = $cyan$v2ray_port$none"
				echo "----------------------------------------------------------------"
				echo
				break
				;;
			*)
				error
				;;
			esac
		done
		if [[ $v2ray_transport -ge 18 ]]; then
			v2ray_dynamic_port_start
		fi
}

v2ray_dynamic_port_start() {

	while :; do
		echo -e "请输入 "$yellow"V2Ray 动态端口开始 "$none"范围 ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(默认开始端口: ${cyan}10000$none):")" v2ray_dynamic_port_start_input
		[ -z $v2ray_dynamic_port_start_input ] && v2ray_dynamic_port_start_input=10000
		case $v2ray_dynamic_port_start_input in
		$v2ray_port)
			echo
			echo " 不能和 V2Ray 端口一毛一样...."
			echo
			echo -e " 当前 V2Ray 端口：${cyan}$v2ray_port${none}"
			error
			;;
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])
			echo
			echo
			echo -e "$yellow V2Ray 动态端口开始 = $cyan$v2ray_dynamic_port_start_input$none"
			echo "----------------------------------------------------------------"
			echo
			break
			;;
		*)
			error
			;;
		esac

	done

	if [[ $v2ray_dynamic_port_start_input -lt $v2ray_port ]]; then
		lt_v2ray_port=true
	fi

	v2ray_dynamic_port_end
}
v2ray_dynamic_port_end() {

	while :; do
		echo -e "请输入 "$yellow"V2Ray 动态端口结束 "$none"范围 ["$magenta"1-65535"$none"]"
		read -p "$(echo -e "(默认结束端口: ${cyan}20000$none):")" v2ray_dynamic_port_end_input
		[ -z $v2ray_dynamic_port_end_input ] && v2ray_dynamic_port_end_input=20000
		case $v2ray_dynamic_port_end_input in
		[1-9] | [1-9][0-9] | [1-9][0-9][0-9] | [1-9][0-9][0-9][0-9] | [1-5][0-9][0-9][0-9][0-9] | 6[0-4][0-9][0-9][0-9] | 65[0-4][0-9][0-9] | 655[0-3][0-5])

			if [[ $v2ray_dynamic_port_end_input -le $v2ray_dynamic_port_start_input ]]; then
				echo
				echo " 不能小于或等于 V2Ray 动态端口开始范围"
				echo
				echo -e " 当前 V2Ray 动态端口开始：${cyan}$v2ray_dynamic_port_start_input${none}"
				error
			elif [ $lt_v2ray_port ] && [[ ${v2ray_dynamic_port_end_input} -ge $v2ray_port ]]; then
				echo
				echo " V2Ray 动态端口结束范围 不能包括 V2Ray 端口..."
				echo
				echo -e " 当前 V2Ray 端口：${cyan}$v2ray_port${none}"
				error
			else
				echo
				echo
				echo -e "$yellow V2Ray 动态端口结束 = $cyan$v2ray_dynamic_port_end_input$none"
				echo "----------------------------------------------------------------"
				echo
				break
			fi
			;;
		*)
			error
			;;
		esac

	done

}
install_info() {
	clear
	echo
	echo " ....准备安装了咯..看看有毛有配置正确了..."
	echo
	echo "---------- 安装信息 -------------"
	echo
	echo -e "$yellow V2Ray 传输协议 = $cyan${transport[$v2ray_transport - 1]}$none"

	if [[ $v2ray_transport == [45] ]]; then
		echo
		echo -e "$yellow V2Ray 端口 = $cyan$v2ray_port$none"
		echo
		echo -e "$yellow 你的域名 = $cyan$domain$none"
		echo
		echo -e "$yellow 域名解析 = ${cyan}我确定已经有解析了$none"
		echo
		echo -e "$yellow 自动配置 TLS = $cyan$install_caddy_info$none"
	elif [[ $v2ray_transport -ge 18 ]]; then
		echo
		echo -e "$yellow V2Ray 端口 = $cyan$v2ray_port$none"
		echo
		echo -e "$yellow V2Ray 动态端口范围 = $cyan${v2ray_dynamic_port_start_input} - ${v2ray_dynamic_port_end_input}$none"
	else
		echo
		echo -e "$yellow V2Ray 端口 = $cyan$v2ray_port$none"
	fi

	echo
	echo "---------- END -------------"
	echo
	pause
	echo
}

install_docker() {
	$cmd update -y
	$cmd install -y docker
}

config() {
	v2ray_id=$uuid
	alterId=0
	docker_config
}

docker_config() {
  mkdir -p /etc/v2ray
  cat > /etc/v2ray/config.json <<EOF
{
  "inbounds": [{
    "port": $v2ray_port,
    "protocol": "vmess",
    "settings": {
      "clients": [
        {
          "id": "$uuid",
          "level": 0,
          "alterId": $alterId
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
}

get_ip() {
	ip=$(curl -s https://ipinfo.io/ip)
	[[ -z $ip ]] && ip=$(curl -s https://api.ip.sb/ip)
	[[ -z $ip ]] && ip=$(curl -s https://api.ipify.org)
	[[ -z $ip ]] && ip=$(curl -s https://ip.seeip.org)
	[[ -z $ip ]] && ip=$(curl -s https://ifconfig.co/ip)
	[[ -z $ip ]] && ip=$(curl -s https://api.myip.com | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
	[[ -z $ip ]] && ip=$(curl -s icanhazip.com)
	[[ -z $ip ]] && ip=$(curl -s myip.ipip.net | grep -oE "([0-9]{1,3}\.){3}[0-9]{1,3}")
	[[ -z $ip ]] && echo -e "\n$red 这垃圾小鸡扔了吧！$none\n" && exit
}

error() {

	echo -e "\n$red 输入错误！$none\n"

}

pause() {

	read -rsp "$(echo -e "按$green Enter 回车键 $none继续....或按$red Ctrl + C $none取消.")" -d $'\n'
	echo
}

docker_start() {
	docker run -d -p $v2ray_port:$v2ray_port --name v2ray --restart=always -v /etc/v2ray:/etc/v2ray teddysun/v2ray:latest
}

show_config_info() {
	echo
	echo
	echo "---------- V2Ray 配置信息 -------------"
	echo
	echo -e "$yellow 地址 (Address) = $cyan${ip}$none"
	echo
	echo -e "$yellow 端口 (Port) = $cyan$v2ray_port$none"
	echo
	echo -e "$yellow 用户ID (User ID / UUID) = $cyan${v2ray_id}$none"
	echo
	echo -e "$yellow 额外ID (Alter Id) = ${cyan}${alterId}${none}"
	echo
	echo -e "$yellow 传输协议 (Network) = ${cyan}${net}$none"
	echo
	echo -e "$yellow 伪装类型 (header type) = ${cyan}${header}$none"
	echo
	echo "---------- END -------------"
	echo
	echo "V2Ray 客户端使用教程: https://www.baidu.com"
	echo
	echo -e "提示: 输入$cyan v2ray url $none可生成 vmess URL 链接 / 输入$cyan v2ray qr $none可生成二维码链接"
	echo
	echo -e "${yellow}免被墙..推荐使用JMS: ${cyan}https://www.baidu.com${none}"
	echo
}

mk_vmess_config() {
  mkdir -p /etc/v2ray
  cat > /etc/v2ray/vmess-config.json <<EOF
  {
    "outbounds" : [
      {
        "sendThrough" : "0.0.0.0",
        "mux" : {
          "enabled" : false,
          "concurrency" : 8
        },
        "protocol" : "vmess",
        "settings" : {
          "vnext" : [
            {
              "address" : "$ip",
              "users" : [
                {
                  "id" : "$uuid",
                  "alterId" : 0,
                  "security" : "none",
                  "level" : 0
                }
              ],
              "port" : $v2ray_port
            }
          ]
        },
        "tag" : "$ip",
        "streamSettings" : {
          "sockopt" : {

          },
          "quicSettings" : {
            "key" : "",
            "security" : "none",
            "header" : {
              "type" : "none"
            }
          },
          "tlsSettings" : {
            "allowInsecure" : false,
            "alpn" : [
              "http\/1.1"
            ],
            "serverName" : "server.cc",
            "allowInsecureCiphers" : false
          },
          "wsSettings" : {
            "path" : "",
            "headers" : {

            }
          },
          "httpSettings" : {
            "path" : "",
            "host" : [
              ""
            ]
          },
          "tcpSettings" : {
            "header" : {
              "type" : "none"
            }
          },
          "kcpSettings" : {
            "header" : {
              "type" : "none"
            },
            "mtu" : 1350,
            "congestion" : false,
            "tti" : 20,
            "uplinkCapacity" : 5,
            "writeBufferSize" : 1,
            "readBufferSize" : 1,
            "downlinkCapacity" : 20
          },
          "security" : "none",
          "network" : "tcp"
        }
      }
    ],
    "routings" : [
      {
        "name" : "all_to_main",
        "domainStrategy" : "AsIs",
        "rules" : [
          {
            "type" : "field",
            "outboundTag" : "main",
            "port" : "0-65535"
          }
        ]
      },
      {
        "name" : "bypasscn_private_apple",
        "domainStrategy" : "IPIfNonMatch",
        "rules" : [
          {
            "type" : "field",
            "outboundTag" : "direct",
            "domain" : [
              "localhost",
              "domain:me.com",
              "domain:lookup-api.apple.com",
              "domain:icloud-content.com",
              "domain:icloud.com",
              "domain:cdn-apple.com",
              "domain:apple-cloudkit.com",
              "domain:apple.com",
              "domain:apple.co",
              "domain:aaplimg.com",
              "domain:guzzoni.apple.com",
              "geosite:cn"
            ]
          },
          {
            "type" : "field",
            "outboundTag" : "direct",
            "ip" : [
              "geoip:private",
              "geoip:cn"
            ]
          },
          {
            "type" : "field",
            "outboundTag" : "main",
            "port" : "0-65535"
          }
        ]
      },
      {
        "name" : "all_to_direct",
        "domainStrategy" : "AsIs",
        "rules" : [
          {
            "type" : "field",
            "outboundTag" : "direct",
            "port" : "0-65535"
          }
        ]
      }
    ]
  }
EOF
}

get_client_file() {
    mk_vmess_config
  	v2ray_client_config="/etc/v2ray/vmess-config.json"
    local _link="$(cat $v2ray_client_config | tr -d [:space:] | base64 -w0)"
    local link="https://233boy.github.io/tools/json.html#${_link}"
    echo
    echo "---------- V2Ray 客户端配置文件链接 -------------"
    echo
    echo -e ${cyan}$link${none}
    echo
    echo " V2Ray 客户端使用教程: https://www.baidu.com"
    echo
    echo
}


install() {
   if [ -f "/etc/v2ray/config.json" ]; then
		echo
		echo " 大佬...你已经安装 V2Ray 啦...无需重新安装"
		echo
		get_client_file
		echo
		exit 1
	fi
	v2ray_config
	install_info
	install_docker
	get_ip
	config
	docker_start
	show_config_info
	get_client_file
	stop_firewall
	docker ps
}

# 简单粗暴，关闭防火墙
stop_firewall(){
	# 笨笨的检测系统类型方法
	if [[ $(command -v yum) ]] && [[ $(command -v systemctl) ]]; then
		# CentOS
		# 关闭防火墙
		systemctl stop firewalld
		# 设置开机禁用防火墙
		systemctl disable firewalld.service
		echo -e "\n$red 该脚本已自动关闭防火墙... $none\n"
	elif [[ $(command -v apt-get) ]] && [[ $(command -v systemctl) ]] && [[ $(command -v ufw) ]]; then
		# Debian or Ubuntu
		# 关闭防火墙
		ufw disable
		echo -e "\n$red 该脚本已自动关闭防火墙...... $none\n"
	fi
}

uninstall() {
		echo -e "
		$red 直接停止docker...$none
		"
}
clear
while :; do
	echo
	echo "........... V2Ray docker 一键安装脚本 .........."
	echo
	echo
	echo " 1. 安装"
	echo
	echo " 2. 卸载"
	echo
	read -p "$(echo -e "请选择 [${magenta}1-2$none]:")" choose
	case $choose in
	1)
		install
		break
		;;
	2)
		uninstall
		break
		;;
	*)
		error
		;;
	esac
done
