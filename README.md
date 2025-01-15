## 关于本项目
在termux-x11里流畅运行KDE Plasma 5.26
![Plasma 安装效果图](https://github.com/fywmjj/termux-plasma-installer/raw/master/images/1.jpg)
FPS稳定60帧  
因为KDE Plasma跑在Arch里  
但KWin是另一个Debian 11的老KWin
还保留了xrender混成器后端  
所以软件渲染仍然十分丝滑流畅

> \[!IMPORTANT]
> 
> 本项目是[kde-yyds 大佬的脚本](https://github.com/kde-yyds/termux-x11-plasma-installer)的**改进版**，开发者只对脚本作改动，如rootfs(容器)本身出现问题请到[本页面](https://github.com/kde-yyds/termux-x11-plasma-image)提issue
> 有**本脚本**相关问题请在这里提issue或pr

## 主要改动：
1. 移除了所有 ghproxy 中转链接
2. 添加了新版本的 changelog
3. 补充了安装脚本的新特性说明
4. 改进了格式和排版
5. 添加了日志文件相关说明
6. 添加了解压时的进度条

## Changelog
2025/1/15 重构安装脚本：
- 优化安装流程，添加进度显示
- 改进错误处理
- 直连GitHub，提升稳定性
- 添加详细日志记录

2023/2/12 更新了LD_PRELOAD环境变量清空方法，修复了老版本安卓无法启动proot的问题  
若之前已经安装了，可以用这个指令修复：
```bash
sed -i 's/env LD_PRELOAD=/env -u LD_PRELOAD/g' /data/data/com.termux/files/home/containers/scripts/*
```

## 使用教程
### 安装termux和termux-x11
Termux：<https://github.com/termux/termux-app/releases/download/v0.118.0/termux-app_v0.118.0+github-debug_arm64-v8a.apk>  
Termux-x11：<https://github.com/fywmjj/termux-plasma-installer/raw/master/termux-x11.apk>

## 其他注意事项
1. 建议把手机的屏幕分辨率调低，保证软件渲染流畅不掉帧  
2. 打开termux-x11，通知栏里按Preferences，把Show additional keyboard勾去掉

## 安装步骤

1. 进入termux，如果没有换源请先运行：
```bash
termux-change-repo
```

2. 下载并运行安装脚本：
```bash
curl -L https://github.com/fywmjj/termux-plasma-installer/raw/master/install.sh | bash
```

## 安装特性
- 支持断点续传：如果安装过程被中断，重新运行即可从断点继续
- 实时进度显示：可以看到下载和解压的实时进度
- 详细日志：安装过程的详细日志保存在 install_plasma.log 中，方便排查问题

*该图是 kde-yyds 大佬的，实际脚本运行不是这样，稍后修改*
![Termux 输出](https://github.com/fywmjj/termux-plasma-installer/raw/master/images/2.jpg)
