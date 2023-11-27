#!/bin/bash

Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Red_background_prefix="\033[41;37m" && Purple_font_prefix="\033[33m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Purple_font_prefix}[注意]${Font_color_suffix}"

#检查用户
check_root(){
	[[ $EUID = 0 ]] && echo -e "${Error} 当前为ROOT账号，无法继续操作，请更换sudo账号或使用 ${Green_background_prefix}su sudo账号名${Font_color_suffix} 命令切换至sudo账号后重新运行脚本（执行后可能会提示输入当前账号的密码）。" && exit 1
}

#检查系统
check_sys() {
    if grep -q -E -i "debian" /etc/issue; then
        release="debian" 
        check_arch
    elif grep -q -E -i "ubuntu" /etc/issue; then
        release="ubuntu"
        check_arch
    elif grep -q -E -i "debian" /proc/version; then
        release="debian"
        check_arch
    elif grep -q -E -i "ubuntu" /proc/version; then
        release="ubuntu"
        check_arch
    else
        read -erp "脚本暂不支持该Linux发行版，如您已自行makepkg并已安装LinuxQQ请输入 yes 并回车继续:" make_num
        [[ -z "${make_num}" ]] && echo -e "${Tip} 您已取消操作." && exit 1
        [[ ${make_num} == yes ]] && LiteLoader_install   
    fi
    bit=$(uname -m)
}

check_arch() {
	get_arch=$(arch)
	if [[ ${get_arch} == "x86_64" ]]; then 
    	arch="amd64"
  	elif [[ ${get_arch} == "aarch64" ]]; then
    	arch="arm64"
  	else
    	echo -e "${Error} 暂不支持该内核版本(${get_arch})..." && exit 1
  	fi
}

LinuxQQ_install() {
    echo -e "${Info} 请输入您的密码以提升权限："
    sudo -v
    echo -e "${Info} 开始安装 LinuxQQ..."
    cd /tmp
    wget https://dldir1.qq.com/qqfile/qq/QQNT/ad5b5393/linuxqq_3.1.2-13107_${arch}.deb
	sudo dpkg -i ./linuxqq_3.1.2-13107_${arch}.deb
	if [ $? = 0 ] ; then
	    echo -e "${Info} LinuxQQ 安装成功."
	else
	    echo -e "${Error} LinuxQQ 安装失败，请截图错误日志加群反馈" && exit 1
	fi
	}

LiteLoader_install() {	
    echo -e "${Info} 正在拉取最新版本的仓库..."
    git clone https://github.com/LiteLoaderQQNT/LiteLoaderQQNT.git
    cd /tmp/LiteLoaderQQNT
    git submodule update --init --recursive -f
    cd /tmp/LiteLoaderQQNT/builtins

    for i in *
	    do
		    if [ -f ./${i}/package.json ]; then
			    cd "${i}"
                	npm install
			    cd ..
		    fi
    done

    echo -e "${Info} 正在安装LiteLoader..."
    sudo rm -rf /opt/QQ/resources/app/LiteLoaderQQNT > /dev/null 2>&1
    sudo mv /tmp/LiteLoaderQQNT /opt/QQ/resources/app

    cd /opt/QQ/resources/app
    echo -e "${Info} 正在修补package.json..."
    sudo sed -i 's|"main": "./app_launcher/index.js"|"main": "LiteLoaderQQNT"|' package.json

    sudo killall -HUP qq

    echo -e "${Info} 安装完成！启动QQ后生效。" && exit 0
}

Insall() {
    check_root
    check_sys
    LinuxQQ_install
    LiteLoader_install
}
Install