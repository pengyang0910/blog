#!/bin/bash
# 部署支持 HTTPS 的 Nginx 容器

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "==> 停止并删除旧的 Nginx 容器..."
docker stop blog-nginx 2>/dev/null || true
docker rm blog-nginx 2>/dev/null || true

echo "==> 启动支持 HTTPS 的 Nginx 容器..."
docker run -d \
  --name blog-nginx \
  --restart unless-stopped \
  -p 80:80 \
  -p 443:443 \
  -v "$PROJECT_ROOT/public:/usr/share/nginx/html:ro" \
  -v "$PROJECT_ROOT/nginx/default.conf:/etc/nginx/conf.d/default.conf:ro" \
  -v "$PROJECT_ROOT/nginx/ssl:/etc/nginx/ssl:ro" \
  nginx:alpine

echo ""
echo "✅ Nginx 容器启动成功！"
echo "   - HTTP  端口: 80  (会自动重定向到 HTTPS)"
echo "   - HTTPS 端口: 443"
echo ""
echo "📝 访问方式："
echo "   https://47.100.130.28"
echo ""
echo "⚠️  注意："
echo "   - 使用的是自签名证书，浏览器会显示安全警告"
echo "   - 点击 '高级' -> '继续访问' 即可"
echo "   - 如需正式证书，请配置域名并使用 Let's Encrypt"
echo ""
echo "🔍 查看容器日志："
echo "   docker logs -f blog-nginx"
