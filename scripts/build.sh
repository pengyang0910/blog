#!/bin/bash

# Hugo 博客构建脚本
# 用于在 Docker 环境下构建静态站点

set -e  # 遇到错误立即退出

# 获取脚本所在目录的父目录（项目根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> 项目根目录: $PROJECT_ROOT"

# 切换到项目根目录
cd "$PROJECT_ROOT"

echo "==> 清理旧的构建锁文件..."
rm -f .hugo_build.lock

echo "==> 使用 Docker 构建 Hugo 站点..."
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -v "$PROJECT_ROOT:/site" \
  hugomods/hugo:0.146.0 \
  hugo -s /site

echo "==> 构建完成！检查关键文件..."
ls -lah public/search/index.html public/index.json 2>/dev/null || echo "警告: 搜索相关文件可能未生成"

echo "==> 列出 public 目录内容..."
ls -lh public/ | head -20

echo ""
echo "✅ 构建成功！可以通过 Nginx 或其他 Web 服务器访问 public/ 目录"
