#!/bin/bash

# Hugo 博客构建脚本
# 用于在 Docker 环境下构建静态站点
# 内容(content)已外置到 $BLOG_DATA(默认 /home/parry/blog/content),以只读方式挂载进容器

set -e  # 遇到错误立即退出

# 获取脚本所在目录的父目录（项目根目录）
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# 数据层目录(文档 + 每篇文章自带的 img/,page bundle),可用环境变量覆盖
BLOG_DATA="${BLOG_DATA:-/home/parry/blog}"
CONTENT_DIR="$BLOG_DATA/content"

echo "==> 项目根目录: $PROJECT_ROOT"
echo "==> 数据目录:   $CONTENT_DIR"

if [ ! -d "$CONTENT_DIR" ]; then
  echo "错误: 内容目录不存在: $CONTENT_DIR"
  echo "      请先运行 migrate-content.sh,或用 BLOG_DATA=... 指定正确路径"
  exit 1
fi

# 切换到项目根目录
cd "$PROJECT_ROOT"

echo "==> 清理旧的构建锁文件..."
rm -f .hugo_build.lock

echo "==> 使用 Docker 构建 Hugo 站点..."
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -v "$PROJECT_ROOT:/site" \
  -v "$CONTENT_DIR:/site/content:ro" \
  hugomods/hugo:0.146.0 \
  hugo -s /site

echo "==> 构建完成！检查关键文件..."
ls -lah public/search/index.html public/index.json 2>/dev/null || echo "警告: 搜索相关文件可能未生成"

echo "==> 列出 public 目录内容..."
ls -lh public/ | head -20

echo ""
echo "✅ 构建成功！可以通过 Nginx 或其他 Web 服务器访问 public/ 目录"