#!/bin/bash

# VitePress 网站部署脚本
# 使用方法：在服务器上执行 ./deploy.sh

echo "=========================================="
echo "开始部署 PathCreator 网站"
echo "=========================================="

# 获取脚本所在目录
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
cd "$SCRIPT_DIR"

# 检查 Node.js
if ! command -v node &> /dev/null; then
    echo "❌ 错误: 未检测到 Node.js"
    echo "请先安装 Node.js 18 或更高版本"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo "❌ 错误: Node.js 版本过低 (当前: $(node -v))"
    echo "需要 Node.js 18 或更高版本"
    exit 1
fi

echo "✅ Node.js 版本: $(node -v)"

# 检查 npm
if ! command -v npm &> /dev/null; then
    echo "❌ 错误: 未检测到 npm"
    exit 1
fi

echo "✅ npm 版本: $(npm -v)"

# 安装依赖
echo ""
echo "📦 正在安装依赖..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ 依赖安装失败"
    exit 1
fi

echo "✅ 依赖安装完成"

# 构建网站
echo ""
echo "🔨 正在构建网站..."
npm run docs:build

if [ $? -ne 0 ]; then
    echo "❌ 构建失败"
    exit 1
fi

# 检查构建输出
if [ ! -d "docs/.vitepress/dist" ]; then
    echo "❌ 错误: 构建输出目录不存在"
    exit 1
fi

echo "✅ 构建完成"
echo ""
echo "=========================================="
echo "部署完成！"
echo "=========================================="
echo "构建输出目录: $(pwd)/docs/.vitepress/dist"
echo ""
echo "下一步："
echo "1. 在 1Panel 中创建网站"
echo "2. 设置运行目录为: $(pwd)/docs/.vitepress/dist"
echo "3. 配置域名和 SSL 证书"
echo "=========================================="

