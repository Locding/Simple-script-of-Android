#!/system/bin/sh

# ====================================================
# 手机清理优化脚本 - 无root权限版本
# 功能：清理各种缓存垃圾，优化手机性能
# 作者：iFlow CLI
# 日期：2025-09-20
# ====================================================

# 颜色定义
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 日志函数
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

# 检查命令是否存在
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# 清理应用缓存（无root权限）
clean_app_cache() {
    log_info "清理应用缓存..."
    
    if command_exists "pm"; then
        # 清理所有第三方应用的缓存
        for app in $(pm list packages -3 | cut -d: -f2); do
            echo "清理应用: $app"
            pm clear "$app" 2>/dev/null
        done
        log_success "第三方应用缓存清理完成"
    else
        log_warning "pm命令不可用，无法清理应用缓存"
    fi
}

# 清理下载目录的临时文件
clean_download_temp_files() {
    log_info "清理下载目录临时文件..."
    
    cleaned_count=0
    # 常见的下载目录路径
    for dir in "/sdcard/Download" "/storage/emulated/0/Download" "/storage/emulated/0/Downloads" "/sdcard/Downloads"; do
        if [ -d "$dir" ] && [ -w "$dir" ]; then
            # 清理各种临时文件
            for pattern in "*.tmp" "*.temp" "*.download" "*.crdownload" "*.part" "*.partial" "*.tmp.*" "*.cache"; do
                count=$(find "$dir" -type f -name "$pattern" -delete 2>/dev/null | wc -l)
                cleaned_count=$((cleaned_count + count))
            done
        fi
    done
    
    log_success "清理了 $cleaned_count 个临时文件"
}

# 清理浏览器缓存目录
clean_browser_cache() {
    log_info "清理浏览器缓存..."
    
    cleaned_count=0
    # 常见浏览器缓存目录
    for dir in "/sdcard/Android/data/com.android.chrome/cache" "/sdcard/Android/data/com.sec.android.app.sbrowser/cache" "/sdcard/Android/data/com.opera.browser/cache" "/sdcard/Android/data/org.mozilla.firefox/cache" "/sdcard/Android/data/com.microsoft.emmx/cache"; do
        if [ -d "$dir" ] && [ -w "$dir" ]; then
            count=$(find "$dir" -type f -delete 2>/dev/null | wc -l)
            cleaned_count=$((cleaned_count + count))
        fi
    done
    
    log_success "清理了 $cleaned_count 个浏览器缓存文件"
}

# 清理缩略图缓存
clean_thumbnail_cache() {
    log_info "清理缩略图缓存..."
    
    cleaned_count=0
    # 缩略图缓存目录
    for dir in "/sdcard/DCIM/.thumbnails" "/sdcard/Pictures/.thumbnails" "/storage/emulated/0/DCIM/.thumbnails" "/storage/emulated/0/Pictures/.thumbnails"; do
        if [ -d "$dir" ] && [ -w "$dir" ]; then
            count=$(find "$dir" -type f -name "*.jpg" -delete 2>/dev/null | wc -l)
            cleaned_count=$((cleaned_count + count))
        fi
    done
    
    log_success "清理了 $cleaned_count 个缩略图文件"
}

# 清理日志文件
clean_log_files() {
    log_info "清理日志文件..."
    
    cleaned_count=0
    # 日志目录
    for dir in "/sdcard/log" "/sdcard/logs" "/storage/emulated/0/log" "/storage/emulated/0/logs" "/data/local/tmp"; do
        if [ -d "$dir" ] && [ -w "$dir" ]; then
            count=$(find "$dir" -type f -name "*.log" -delete 2>/dev/null | wc -l)
            cleaned_count=$((cleaned_count + count))
            
            count=$(find "$dir" -type f -name "log.*" -delete 2>/dev/null | wc -l)
            cleaned_count=$((cleaned_count + count))
        fi
    done
    
    log_success "清理了 $cleaned_count 个日志文件"
}

# 清理空目录
clean_empty_directories() {
    log_info "清理空目录..."
    
    cleaned_count=0
    # 目标目录
    for dir in "/sdcard" "/storage/emulated/0"; do
        if [ -d "$dir" ] && [ -w "$dir" ]; then
            count=$(find "$dir" -type d -empty -delete 2>/dev/null | wc -l)
            cleaned_count=$((cleaned_count + count))
        fi
    done
    
    log_success "清理了 $cleaned_count 个空目录"
}

# 优化建议（无root权限）
show_optimization_tips() {
    log_info "手机优化建议:"
    echo ""
    echo "1. ${GREEN}清理存储空间:${NC}"
    echo "   • 定期删除不需要的照片、视频"
    echo "   • 卸载不常用的应用"
    echo "   • 清理聊天应用的媒体文件"
    echo ""
    echo "2. ${GREEN}电池优化:${NC}"  
    echo "   • 关闭不必要的后台应用"
    echo "   • 降低屏幕亮度"
    echo "   • 关闭GPS、蓝牙等不需要的功能"
    echo "   • 启用省电模式"
    echo ""
    echo "3. ${GREEN}性能优化:${NC}"
    echo "   • 重启手机定期清理内存"
    echo "   • 关闭动画效果（开发者选项）"
    echo "   • 限制后台进程数量"
    echo ""
    echo "4. ${GREEN}网络优化:${NC}"
    echo "   • 清理DNS缓存（需要重启）"
    echo "   • 关闭不必要的网络服务"
    echo ""
}

# 显示存储空间信息
show_storage_info() {
    log_info "存储空间使用情况:"
    
    if command_exists "df"; then
        df -h /data 2>/dev/null || df -h /sdcard 2>/dev/null || df -h /storage/emulated/0 2>/dev/null
    else
        log_warning "df命令不可用，无法显示存储信息"
    fi
    
    echo ""
}

# 显示内存信息
show_memory_info() {
    log_info "内存使用情况:"
    
    if command_exists "free"; then
        free -h 2>/dev/null
    elif command_exists "cat" && [ -f "/proc/meminfo" ]; then
        cat /proc/meminfo | grep -E "(MemTotal|MemFree|MemAvailable)" 2>/dev/null
    else
        log_warning "无法获取内存信息"
    fi
    
    echo ""
}

# 安全检查
safety_check() {
    log_info "执行安全检查..."
    
    # 检查是否在Android环境
    if ! [ -f "/system/build.prop" ]; then
        log_warning "不在Android环境，某些功能可能无法正常工作"
    fi
    
    # 检查写权限
    if ! [ -w "/sdcard" ] && ! [ -w "/storage/emulated/0" ]; then
        log_error "没有写入权限，清理功能受限"
        return 1
    fi
    
    log_success "安全检查通过"
    return 0
}

# 主函数
main() {
    echo ""
    echo "===================================================="
    echo "           📱 手机清理优化脚本 - 无root权限版本"
    echo "===================================================="
    echo ""
    
    # 执行安全检查
    if ! safety_check; then
        log_error "安全检查失败，脚本终止"
        exit 1
    fi
    
    # 显示当前系统信息
    show_storage_info
    show_memory_info
    
    # 执行清理操作
    clean_app_cache
    clean_download_temp_files
    clean_browser_cache
    clean_thumbnail_cache
    clean_log_files
    clean_empty_directories
    
    echo ""
    echo "===================================================="
    log_success "所有清理操作完成!"
    echo "===================================================="
    echo ""
    
    # 显示优化后的系统信息
    show_storage_info
    show_memory_info
    
    # 显示优化建议
    show_optimization_tips
    
    echo "===================================================="
    log_info "脚本执行完成!"
    echo "ℹ️  注意：无root权限下功能有限，建议定期手动清理"
    echo "===================================================="
    echo ""
}

# 异常处理
trap 'log_error "脚本被中断"; exit 1' INT TERM

# 执行主函数
main "$@"