#!/bin/bash
# 生成自签名 SSL 证书
# 注意：自签名证书浏览器会显示"不安全"警告，仅用于测试或内网环境

set -e

echo "开始生成自签名 SSL 证书..."

# 创建证书目录
mkdir -p ./nginx/ssl

# 生成私钥和证书（有效期 365 天）
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout ./nginx/ssl/key.pem \
  -out ./nginx/ssl/cert.pem \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=Personal/OU=Blog/CN=47.100.130.28"

echo "✅ SSL 证书生成完成！"
echo "   证书文件: ./nginx/ssl/cert.pem"
echo "   私钥文件: ./nginx/ssl/key.pem"
echo ""
echo "⚠️  注意事项："
echo "   1. 这是自签名证书，浏览器会显示安全警告"
echo "   2. 生产环境建议使用 Let's Encrypt 等正式证书"
echo "   3. 如果有域名，可以使用 certbot 获取免费证书"
