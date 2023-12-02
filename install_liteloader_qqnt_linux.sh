#!/usr/bin/env bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH

ghproxy="https://mirror.ghproxy.com/"
tty=$(ps -ef | grep -E " DISPLAY=$display " | awk '{print $6}') #获取tty
user=$(who | grep ${tty} | cut -d ' ' -f1) #通过tty获取当前图形界面登录的用户
groups=$(groups ${user} | cut -d ' ' -f3) #获取用户所在用户组
Green_font_prefix="\033[32m" && Red_font_prefix="\033[31m" && Red_background_prefix="\033[41;37m" && Purple_font_prefix="\033[33m" && Font_color_suffix="\033[0m"
Info="${Green_font_prefix}[信息]${Font_color_suffix}"
Error="${Red_font_prefix}[错误]${Font_color_suffix}"
Tip="${Purple_font_prefix}[注意]${Font_color_suffix}"

#检查用户
check_root(){
    [[ $EUID != 0 ]] && echo -e "${Error} 当前用户没有ROOT权限，无法继续操作，请使用 ${Green_background_prefix}sudo -i${Font_color_suffix} 命令获取临时ROOT权限(不可直接su登录root用户),执行后可能会提示输入当前账号的密码。" && exit 1 #|| echo -e "${Error} 当前为root用户，请先切换至sudo用户后输入${Green_background_prefix}sudo -i${Font_color_suffix} 命令获取临时ROOT权限后再运行脚本。" && exit 1
    [[ -z "${user}" ]] && echo -e "${Error} 当前脚本需要桌面环境运行，请安装图形界面并登录后再运行该脚本，即将退出脚本。" && exit 1
    
}

#检查系统
check_sys() {
    if grep -q -E -i "debian" /etc/issue; then
        release="debian" 
    elif grep -q -E -i "ubuntu" /etc/issue; then
        release="ubuntu"
    elif grep -q -E -i "debian" /proc/version; then
        release="debian"
    elif grep -q -E -i "ubuntu" /proc/version; then
        release="ubuntu"
    else
        read -erp "脚本暂不支持该Linux发行版，如您已自行makepkg并已安装LinuxQQ请输入 yes 并回车继续:" make_num
        [[ -z "${make_num}" ]] && echo -e "${Tip} 您已取消操作." && exit 1
        [[ ${make_num} == yes ]] && LiteLoader_install   
    fi
    bit=$(uname -m)
    check_arch

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

check_nodejs() {
    nodejs_version=$(node -v| cut -d "." -f 1 | sed 's/[^0-9]//g') #获取nodejs版本
    npm_version=$(npm -v| cut -d "." -f 1 | sed 's/[^0-9]//g') #获取npm版本
    [[ -z "${nodejs_version}" ]] && echo -e "${Error} 当前系统未安装 nodejs ，请安装nodejs 16+，即将退出脚本。" && sleep 5 && exit 1
    [[  ${nodejs_version} -lt 16 ]] && echo -e "${Error} 当前系统安装的nodejs ${nodejs_version} 版本过低，请安装nodejs 16+，即将退出脚本。" && sleep 5 && exit 1
    [[  -z "${npm_version}" ]] && sudo apt install npm -y
    LinuxQQ_install
    
}

LinuxQQ_install() {
    sudo apt update && sudo apt upgrade -y
    sudo apt-get install wget curl gnupg git -y #安装后续所需软件包
    echo -e "${Info} 开始安装 LinuxQQ..."
    cd /tmp/
    wget https://dldir1.qq.com/qqfile/qq/QQNT/ad5b5393/linuxqq_3.1.2-13107_${arch}.deb
	sudo dpkg -i ./linuxqq_3.1.2-13107_${arch}.deb
	if [ $? = 0 ] ; then
	    echo -e "${Info} LinuxQQ 安装成功..."
        sudo rm -rf linuxqq_3.1.2-13107_${arch}.deb
	else
	    echo -e "${Error} LinuxQQ 安装失败，请截图错误日志加群反馈" && rm -rf sudo rm -rf linuxqq_3.1.2-13107_${arch}.deb && exit 1
	fi
    LiteLoader_install

}

LiteLoader_install() {	
    echo -e "${Info} 正在拉取最新版本的仓库..."
    git clone ${ghproxy}https://github.com/LiteLoaderQQNT/LiteLoaderQQNT.git
    cd /tmp/LiteLoaderQQNT
    sudo sed -i 's/url = /url = https:\/\/mirror.ghproxy.com\//g' ./.gitmodules
    git submodule sync
    git submodule update --init --recursive -f #添加子模块代理并从主仓库拉取子模块
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
    cd /tmp/
    wget ${ghproxy}https://raw.githubusercontent.com/soloxiaoye2022/LiteLoaderQQNT-for-Linux_desktop-depoly/main/LiteLoaderQQNT-Plugin-Chronocat.tar.gz
    mkdir /home/${user}/Documents/LiteLoaderQQNT/ && mkdir /home/${user}/Documents/LiteLoaderQQNT/plugins/
    mkdir /home/${user}/Documents/LiteLoaderQQNT/plugins/LiteLoaderQQNT-Plugin-Chronocat/
    sudo tar -zxvf LiteLoaderQQNT-Plugin-Chronocat.tar.gz -C /home/${user}/Documents/LiteLoaderQQNT/plugins/LiteLoaderQQNT-Plugin-Chronocat/
    sudo rm -rf LiteLoaderQQNT-Plugin-Chronocat.tar.gz
    sudo chown -R ${user}:${groups} /home/${user}/Documents/LiteLoaderQQNT/ #修改LiteLoaderQQNT所有者和用户组确保QQ有权限访问
    echo -e "${Info} LinuxQQ 安装完成！即将启动QQ，请扫码登录Bot账号。如QQ未弹窗请手动启动QQ。" 
    sudo killall -HUP qq > /dev/null 2>&1 & #杀死QQ原有进程
    sudo chown -R ${user}:${groups} /opt/QQ/ #修改QQ所有者以及组确保图形界面可打开
    sudo -u ${user} nohup qq& > qq.log 2>&1 &\r #启动LinuxQQ
    nohup disown > /dev/null & #QQ进程与终端分离保持后台运行
    
    
    while true; do #获取token
        if [[ -e /home/${user}/.chronocat/config/chronocat.yml ]]; then
            token=$(cat /home/${user}/.chronocat/config/chronocat.yml | grep "token: '.*'" | head -n1 |cut -d "'" -f 2 )
            sleep 3
            if [ $token ]; then
                Redis_install
                break
            fi
        fi
    done

}

TRSS_Yunzai_install() {
    echo -e "${Info} 开始安装 TRSS云崽..."
    cd /opt/ && sudo mkdir Yunzai
    git clone --depth 1 ${ghproxy}https://github.com/TimeRainStarSky/Yunzai
    cd Yunzai
    git clone --depth 1 ${ghproxy}https://github.com/TimeRainStarSky/Yunzai-genshin plugins/genshin
    git clone --depth 1 ${ghproxy}https://github.com/yoimiya-kokomi/miao-plugin plugins/miao-plugin
    git clone --depth 1 ${ghproxy}https://github.com/TimeRainStarSky/TRSS-Plugin plugins/TRSS-Plugin
    git clone -b red ${ghproxy}https://github.com/xiaoye12123/ws-plugin.git ./plugins/ws-plugin
    npm install -g pnpm && pnpm i
    set_config
    endTime=`date +%s`
    ((outTime=($endTime-$startTime)))
    echo -e "${Info} 安装用时 ${outTime} s ..."
    node app
    

}

Redis_install() {
    echo -e "${Info} 开始安装 Redis..."
    if [[ ${release} == "ubuntu" ]]; then 
        apt update -y
        apt upgrade -y
        echo -e "${Info} ceshi..."
        apt install redis-server -y
    elif [[ ${release} == "debian" ]]; then
        curl https://packages.redis.io/gpg | apt-key add -
        echo "deb https://packages.redis.io/deb $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/redis.list
        apt-get update -y 
        apt-get install redis-server -y
    fi
    systemctl start redis-server
    systemctl enable redis-server
    TRSS_Yunzai_install


}

set_config() {
    echo -e "${Info} 开始配置chronocat连接..."
    nohup node app > /dev/null 2>&1 &
    sleep 2
    kill -TERM "$!"
    cat <<EOF >> /opt/Yunzai/plugins/ws-plugin/config/config/ws-config.yaml
    
  - name: chronocat
    address: 127.0.0.1:16530
    type: 4
    accessToken: ${token}
    reconnectInterval: 5
    maxReconnectAttempts: 0
    uin: stdin
EOF

    if [ $? -eq 0 ]; then
        echo -e "${Info} chronocat连接配置成功..."
    else
        echo -e "${Error} chronocat连接配置失败，请手动配置..."
    fi
    
    read -erp "是否需要配置 真寻ws 连接?默认为n [ y/n ]:" nb_num
    [[ -z "${nb_num}" ]] && echo -e "${Tip} 您已取消操作." && exit 1
    if [[ ${nb_num} == 'y' || ${nb_num} == 'yes' ]]; then
        read -erp "请输入真寻ws连接地址或者真寻ws连接端口:" ws_num
        expr $ws_num + 0 > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            ws_address=ws://127.0.0.1:$ws_num/onebot/v11/ws
        else
            ws_address=${ws_num} 
        fi
    fi

    set_bot_qq

    cat <<EOF >> /opt/Yunzai/plugins/ws-plugin/config/config/ws-config.yaml
  - name: 真寻ws
    address: ${ws_address}
    type: 1
    reconnectInterval: 5
    maxReconnectAttempts: 0
    uin: ${bot_qq}
EOF
    echo -e "${Info} 配置完成..."
    sudo chown -R ${user}:${groups} /opt/Yunzai/ #修改Yunzai所有者和用户组确方便图形界面用户修改配置

}

set_bot_qq() {
    read -erp "请设置Bot QQ号:" bot_qq
    [[ -z "${bot_qq}" ]] && echo -e "${Eroor} Bot QQ号不能为空，请重新输入！" && set_bot_qq
    expr $bot_qq + 0 > /dev/null 2>&1
    [[ $? -eq 1 ]] && echo -e "${Eroor} Bot QQ号错误，请输入正确的Bot QQ号！" && set_bot_qq
    echo -e "${Info} Bot QQ号: $bot_qq 设置成功..." && set_master_qq

}

set_master_qq(){
    read -erp "请设置Bot主人QQ号:" masterqq
    [[ -z "${master_qq}" ]] && echo -e "${Eroor} 主人 QQ号不能为空，请重新输入！" && master_qq
    expr $master_qq + 0 > /dev/null 2>&1
    [[ $? -eq 1 ]] && echo -e "${Eroor} 主人 QQ号错误，请输入正确的Bot QQ号！" && master_qq
    echo -e "${Info} 主人 QQ号： $master_qq 设置成功..."
    sed -i "s/masterQQ:.*/masterQQ:\n  - \"$master_qq\"/" ./config/config/other.yaml
    sed -i "/master:/a\  - \"$bot_qq:$master_qq\"" ./config/config/other.yaml

}


Install() {
    echo -e "${Info} 开始安装..."
    startTime=`date +%s`
    sudo -v
    check_root
    check_sys
    check_nodejs

}

Install
