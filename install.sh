#!/data/data/com.termux/files/usr/bin/bash
set -e  # 遇到错误立即退出
TERMUX_PREFIX="/data/data/com.termux/files"
LOG_FILE="install_plasma.log"

# 输出彩色信息
print_info() {
    echo -e "\033[1;34m[INFO]\033[0m $1"
}

print_error() {
    echo -e "\033[1;31m[ERROR]\033[0m $1" >&2
}

# 检查并安装依赖
check_dependencies() {
    local deps=("aria2" "p7zip" "coreutils" "tar" "xz-utils" "pv")
    print_info "检查依赖..."
    
    apt update
    apt install x11-repo -y
    
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            print_info "安装 $dep..."
            apt install -y "$dep" >>"$LOG_FILE" 2>&1
        fi
    done
}

# 下载并验证文件
download_verify() {
    local url="$1"
    local file="$2"
    local sha1="$3"
    
    echo "$sha1  $file" > "$file.sha1"
    
    if sha1sum -c "$file.sha1" &>/dev/null; then
        print_info "$file 已缓存"
        return 0
    fi
    
    print_info "下载 $file..."
    # 添加 --quiet 参数关闭通知，只显示进度条
    aria2c --quiet --show-console-readout=true -x 16 -s 16 "https://github.com/kde-yyds/termux-x11-plasma-image/releases/download/v1.0/$file"
    
    if ! sha1sum -c "$file.sha1" &>/dev/null; then
        print_error "$file 下载失败，请检查 $LOG_FILE"
        return 1
    fi
    
    print_info "$file 下载成功"
}

# 主函数
main() {
    # 检查依赖
    check_dependencies
    
    # 下载并解压 termux prefix
    download_verify "termux.tar.xz" "termux.tar.xz" "5b34da13d9c7876183c6ec2446214edac2d6d470"
    if [ -f termux.tar.xz ]; then
        print_info "解压 termux.tar.xz..."
        pv termux.tar.xz | tar -xJf - -C "$TERMUX_PREFIX"
    fi
    
    # 下载 plasma 分卷文件
    local plasma_parts=(
        "plasma.tar.xz.7z.001:25d2ff2bf287009bdbda8b4871f6431d30a6450e"
        "plasma.tar.xz.7z.002:38bc1a0aa1c29b066d0f9cb47d94b799c65ed313"
        "plasma.tar.xz.7z.003:303f41019d2a3f0d2fe0aeef7063ff7c301ed4e5"
        "plasma.tar.xz.7z.004:cc700b4cae43ddaeddfd5ed03974a97ebb2f68a7"
        "plasma.tar.xz.7z.005:c712ff34edf0ef97c12c72c57b14bf66ca22e51a"
    )
    
    for part in "${plasma_parts[@]}"; do
        IFS=':' read -r file sha1 <<< "$part"
        download_verify "$file" "$file" "$sha1"
    done
    
    # 解压 plasma 文件
    if [ -f plasma.tar.xz.7z.005 ] && [ ! -f plasma.tar.xz ]; then
        print_info "解压 plasma.tar.xz.7z..."
        # 使用pv显示7z的解压进度
        7z x -so plasma.tar.xz.7z.001 2>/dev/null | pv -N "7z解压" > plasma.tar.xz
    fi
    
    if [ -f plasma.tar.xz ] && [ ! -d containers ]; then
        print_info "解压 plasma.tar.xz..."
        # 使用pv显示tar的解压进度
        pv plasma.tar.xz | tar -xJf - -C "$TERMUX_PREFIX/home/"
    fi
    
    # 清理缓存文件
    print_info "清理临时文件..."
    rm -rf termux.tar.xz termux.tar.xz.sha1 plasma.tar.xz* >>"$LOG_FILE" 2>&1
    
    # 创建启动脚本
    if [ ! -f "$TERMUX_PREFIX/usr/bin/plasma" ]; then
        print_info "创建启动脚本..."
        cat > "$TERMUX_PREFIX/usr/bin/plasma" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
termux-x11 :1 &
sleep 2
/data/data/com.termux/files/home/containers/scripts/debianbullseye_xrenderkwin_xfce4-panel.sh &
/data/data/com.termux/files/home/containers/scripts/archlinuxarm_plasma.sh
EOF
        chmod +x "$TERMUX_PREFIX/usr/bin/plasma"
        
        # 修复脚本中的 LD_PRELOAD
        sed -i 's/env LD_PRELOAD=/env -u LD_PRELOAD/g' "$TERMUX_PREFIX/home/containers/scripts/"*
    fi
    
    print_info "安装完成！输入 plasma 并回车即可启动 termux-x11 + KDE Plasma"
}

# 执行主函数
main "$@"
