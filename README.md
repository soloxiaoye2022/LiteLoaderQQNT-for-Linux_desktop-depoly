# LiteLoaderQQNT-for-Linux-depoly


## Linux下NoneBot使用ws插件连接NTQQ教程
**教程仅供参考，切勿直接照抄

* 零，原理
** 原理就是用LiteLoaderQQNT取代官方的加载器，借助 Chronocat 插件获取到的token，用WS插件的red协议连接，最后再使用WS添加nonebot的反代地址，完成nonebot的连接(相当于一个账号上面运行了两个Bot)

## 自动部署脚本

** 偷懒可以用这个，也可以下载下来按照自己需求来改（脚本仅支持Ubuntu/Debian）

* 1.使用 sudo -i 命令获取临时root权限以运行脚本
  
```bash

sudo -i #可能需要输入当前用户的密码,如果已经是root用户登录终端可忽略这一步

```

* 2.默认安装脚本
  
```bash

bash <(curl -s -L https://raw.githubusercontent.com/soloxiaoye2022/LiteLoaderQQNT-for-Linux-depoly/main/install_liteloader_qqnt_linux.sh)

```

* 3.国内服务器可使用

```bash

bash <(curl -s -L https://mirror.ghproxy.com/https://raw.githubusercontent.com/soloxiaoye2022/LiteLoaderQQNT-for-Linux-depoly/main/install_liteloader_qqnt_linux.sh)

```

以下为手动部署过程

一、准备
1.带GUI的电脑/服务器(不带GUI怎么运行NTQQ啊)，以及良好的网络环境
2.NTQQ3.1.2_13107
版本高于这个的需要自己降级，保证低于16183即可，这里放上3.1.2_13107版本的x86_64以及aarch64架构的deb包,需要的自取，Arch Linux可以参考这个PKGBUILD来自己makepkg，或者安装我发群里的打包好的，其他的发行版可以看看自己软件源/社区，这里就不多讲了。
3.必要的一些工具
1.Chronocat (提前自己下好)


二、教程
1.部署TRSS-Yunzai ，部署位置视个人喜好而定
# 克隆项目并安装 genshin miao-plugin TRSS-Plugin
git clone --depth 1 https://github.com/TimeRainStarSky/Yunzai
cd Yunzai
git clone --depth 1 https://github.com/TimeRainStarSky/Yunzai-genshin plugins/genshin
git clone --depth 1 https://github.com/yoimiya-kokomi/miao-plugin plugins/miao-plugin
git clone --depth 1 https://github.com/TimeRainStarSky/TRSS-Plugin plugins/TRSS-Plugin 
git clone --depth 1 -b red https://github.com/xiaoye12123/ws-plugin plugins/ws-plugin

# 安装 pnpm,需要root权限
sudo npm install -g pnpm

# 安装依赖
pnpm i

# 安装redis数据库，这里以Arch为例，其他发行版安装自行谷歌
sudo pacman -S redis
sudo systemctl enable --now redis.service # 可选








2.按照 LiteLoaderQQNT 的README文件所示进行安装和修补package.json操作，这里推荐用下面的脚本进行安装
#!/bin/bash

echo "请输入您的密码以提升权限："
sudo -v

echo "正在拉取最新版本的仓库..."
cd /tmp
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

echo "正在安装LiteLoader..."
sudo rm -rf /opt/QQ/resources/app/LiteLoaderQQNT > /dev/null 2>&1
sudo mv /tmp/LiteLoaderQQNT /opt/QQ/resources/app

cd /opt/QQ/resources/app
echo "正在修补package.json..."
sudo sed -i 's|"main": "./app_launcher/index.js"|"main": "LiteLoaderQQNT"|' package.json

sudo killall -HUP qq

echo "安装完成！启动QQ后生效。"
exit 0



3.启动NTQQ ，登陆Bot账号，打开设置，不出意外的话就能看到LiteLoaderQQNT的相关配置界面，最小化NTQQ，将Chronocat插件解压后放到
～/Documents/LiteLoaderQQNT/plugins下

去 ~/.chronocat/config文件夹下，将chronocat.yml文件里面red协议部分的token复制下来，并记住端口号，下面的步骤会用到


4.在TRSS-Yunzai的目录下打开终端执行 node app 指令启动TRSS-Yunzai，接着重点来了，在终端 顺序 复制输入 以下 红色颜色字体 的指令：
#ws添加连接 
chronocat,4
127.0.0.1:16530,token,重连间隔,最大重连次数 
这里token和端口替换成上面复制的，重连间隔默认为5，最大重连次数默认为0,二者可不填

5.私聊Bot，复制发送 以下 红色颜色字体 的指令：
		#设置主人
	然后将终端中出现的验证码直接发给Bot，至此设置主人完毕




6.私聊Bot，顺序 复制发送 以下 红色颜色字体 的指令：
		#ws添加连接
		nonebot,1
		ws://127.0.0.1:8080/onebot/v11/ws (这里的端口视个人而定)
这里nonebot后面的1是ws反向连接，完整的连接类型如下：
1:反向ws连接 2:正向ws连接 3:gscore连接 4:red连接 5:正向http 6:反向http

7.新开终端/标签，启动你的Bot,完事


这是一个ps，应该没人看吧：
CTRL + ALT + T = 打开一个新终端
CTRL + SHIFT + F4 = 在对应目录下打开新终端
CTRL + SHIFT + T = 打开新标签
