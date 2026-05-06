#!/bin/bash

# 记忆小超人 APP - 快速启动脚本
# Memory Hero App - Quick Start Script

set -e

echo "🚀 记忆小超人 APP - 快速启动"
echo "================================"

# 检查 Flutter 是否安装
if ! command -v flutter &> /dev/null; then
    echo "❌ 错误：未找到 Flutter，请先安装 Flutter SDK"
    echo "   下载地址：https://flutter.dev/docs/get-started/install"
    exit 1
fi

echo "✅ Flutter 已安装"
flutter --version

# 进入项目目录
cd "$(dirname "$0")"

echo ""
echo "📦 安装依赖..."
flutter pub get

echo ""
echo "🔍 检查代码..."
flutter analyze || echo "⚠️  代码检查发现一些问题，但不影响运行"

echo ""
echo "📱 准备启动应用..."
echo ""
echo "请选择启动方式:"
echo "1. 运行到已连接的设备 (推荐)"
echo "2. 启动 Android 模拟器"
echo "3. 启动 iOS 模拟器"
echo "4. 仅构建 APK"
echo ""
read -p "请输入选项 (1-4): " choice

case $choice in
    1)
        echo ""
        echo "🔌 请确保已连接设备或启动模拟器..."
        flutter devices
        echo ""
        echo "🚀 启动应用..."
        flutter run
        ;;
    2)
        echo ""
        echo "🤖 启动 Android 模拟器..."
        flutter emulators --launch flutter_emulator 2>/dev/null || echo "⚠️  无法启动模拟器，请手动启动"
        sleep 5
        flutter run
        ;;
    3)
        echo ""
        echo "🍎 启动 iOS 模拟器..."
        open -a Simulator 2>/dev/null || echo "⚠️  无法启动模拟器，请手动启动"
        sleep 5
        flutter run
        ;;
    4)
        echo ""
        echo "📦 构建 APK..."
        flutter build apk --release
        echo ""
        echo "✅ APK 构建完成！"
        echo "   位置：build/app/outputs/flutter-apk/app-release.apk"
        ;;
    *)
        echo "❌ 无效选项"
        exit 1
        ;;
esac

echo ""
echo "================================"
echo "✨ 完成！"
echo ""
