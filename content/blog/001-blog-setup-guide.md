---
title: "从零搭建个人博客（一）：Hugo + PaperMod + Docker + Nginx"
date: 2026-03-03
slug: "blog-setup-guide"
weight: 1
draft: false
tags: ["Hugo", "博客", "教程", "Docker"]
categories: ["技术"]
summary: "记录本博客的完整搭建过程，涵盖 Hugo 静态站点生成、PaperMod 主题配置、Docker 构建、Nginx 部署及 HTTPS 配置。"
ShowToc: true
TocOpen: false
comments: true
---

## 技术栈概览

本博客基于以下技术搭建：

| 组件 | 版本 / 说明 |
|------|------------|
| **Hugo** | v0.146.0（通过 Docker 运行） |
| **主题** | PaperMod |
| **构建工具** | Docker（hugomods/hugo） |
| **Web 服务器** | Nginx（nginx:alpine） |
| **HTTPS** | 自签名证书 / Let's Encrypt |

整体思路：**Hugo 生成静态文件 → Nginx 提供访问服务**，两者都跑在 Docker 容器里，无需在宿主机安装任何额外依赖。

---

## 一、环境准备

### 安装 Docker

```bash
# Ubuntu / Debian
curl -fsSL https://get.docker.com | sh

# 将当前用户加入 docker 组（避免每次 sudo）
sudo usermod -aG docker $USER
newgrp docker

# 验证安装
docker --version
```

### 克隆项目（或新建）

```bash
# 新建博客目录
mkdir -p /srv/blog && cd /srv/blog

# 初始化 git（可选）
git init
```

---

## 二、Hugo 项目初始化

由于使用 Docker 运行 Hugo，不需要在本机安装 Hugo 二进制。

```bash
# 使用 Docker 创建新站点
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -v "$(pwd):/site" \
  hugomods/hugo:0.146.0 \
  hugo new site /site --force
```

项目结构如下：

```
blog/
├── archetypes/       # 文章模板
├── content/          # 内容目录（Markdown 文章）
│   ├── blog/         # 博客文章
│   ├── garden/       # 数字花园
│   ├── kb/           # 知识库
│   ├── pages/        # 独立页面（About 等）
│   └── projects/     # 项目展示
├── layouts/          # 自定义模板（覆盖主题）
├── static/           # 静态资源（favicon 等）
├── themes/           # 主题目录
├── nginx/            # Nginx 配置
├── scripts/          # 构建 & 部署脚本
├── public/           # 构建输出（不提交 git）
└── hugo.toml         # 站点配置文件
```

---

## 三、安装 PaperMod 主题

```bash
# 使用 git submodule 方式安装（推荐，便于后续更新）
git submodule add --depth=1 \
  https://github.com/adityatelange/hugo-PaperMod.git \
  themes/PaperMod

# 如果已克隆仓库，需要初始化子模块
git submodule update --init --recursive
```

---

## 四、配置 hugo.toml

以下是本博客的核心配置，可按需调整：

```toml
baseURL = "https://your-server-ip/"
languageCode = "zh-cn"
title = "你的博客名"
theme = "PaperMod"
enableRobotsTXT = true
enableEmoji = true

# 分页
[pagination]
  pagerSize = 10

# 输出格式（搜索功能需要 JSON）
[outputs]
  home = ["HTML", "RSS", "JSON"]

[params]
  defaultTheme = "auto"          # auto / light / dark
  ShowReadingTime = true
  ShowWordCount = true
  ShowCodeCopyButtons = true
  ShowPostNavLinks = true
  ShowBreadCrumbs = true
  ShowToc = true
  TocOpen = false
  DateFormat = "2006-01-02"
  ShowLastMod = true
  author = "你的名字"
  description = "博客描述"

  # 搜索配置（Fuse.js）
  [params.fuseOpts]
    isCaseSensitive = false
    shouldSort = true
    threshold = 0.4
    keys = ["title", "permalink", "summary", "content"]

# 首页 Profile 模式
[params.profileMode]
  enabled = true
  title = "你的博客名"
  subtitle = "一句话简介"
  imageUrl = "/favicon.svg"
  imageWidth = 150
  imageHeight = 150

  [[params.profileMode.buttons]]
    name = "📝 博客"
    url = "/blog"

# 导航菜单
[[menu.main]]
  name = "📝 博客"
  url = "/blog/"
  weight = 10
[[menu.main]]
  name = "🔍 搜索"
  url = "/search/"
  weight = 5
```

---

## 五、创建内容页面

### 启用搜索页

新建 `content/search.md`：

```markdown
---
title: "搜索"
layout: "search"
summary: "search"
placeholder: "搜索文章..."
---
```

### 启用归档页

新建 `content/archives.md`：

```markdown
---
title: "归档"
layout: "archives"
url: "/archives/"
summary: archives
---
```

### 写第一篇文章

```bash
# 在 content/blog/ 下新建文章
cat > content/blog/hello.md << 'EOF'
---
title: "Hello World"
date: 2026-03-03
draft: false
tags: ["博客"]
categories: ["日志"]
summary: "第一篇博客文章。"
---

欢迎来到我的博客！
EOF
```

---

## 六、构建静态站点

### 构建脚本 `scripts/build.sh`

```bash
#!/bin/bash
set -e

PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$PROJECT_ROOT"

# 清理旧的构建锁
rm -f .hugo_build.lock

# 使用 Docker 构建
docker run --rm \
  -u "$(id -u):$(id -g)" \
  -v "$PROJECT_ROOT:/site" \
  hugomods/hugo:0.146.0 \
  hugo -s /site

echo "✅ 构建完成！静态文件位于 public/ 目录"
```

执行构建：

```bash
chmod +x scripts/build.sh
bash scripts/build.sh
```

构建产物输出到 `public/` 目录，这就是最终要提供访问的静态文件。

---

## 七、Nginx 配置与部署

### 7.1 生成自签名 SSL 证书

```bash
mkdir -p nginx/ssl

openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
  -keyout nginx/ssl/key.pem \
  -out nginx/ssl/cert.pem \
  -subj "/C=CN/ST=Beijing/L=Beijing/O=Personal/OU=Blog/CN=your-server-ip"
```

> 如果有正式域名，建议使用 [Let's Encrypt](https://letsencrypt.org/) + certbot 获取免费证书。

### 7.2 Nginx 配置文件 `nginx/default.conf`

```nginx
# HTTP → HTTPS 重定向
server {
  listen 80;
  server_name _;
  return 301 https://$host$request_uri;
}

# HTTPS 服务
server {
  listen 443 ssl http2;
  server_name _;

  ssl_certificate     /etc/nginx/ssl/cert.pem;
  ssl_certificate_key /etc/nginx/ssl/key.pem;
  ssl_protocols TLSv1.2 TLSv1.3;
  ssl_ciphers HIGH:!aNULL:!MD5;
  ssl_prefer_server_ciphers on;
  ssl_session_cache shared:SSL:10m;
  ssl_session_timeout 10m;

  root /usr/share/nginx/html;
  index index.html;

  location / {
    try_files $uri $uri/ =404;
  }
}
```

### 7.3 启动 Nginx 容器

```bash
# 停止旧容器（如果存在）
docker stop blog-nginx 2>/dev/null || true
docker rm blog-nginx 2>/dev/null || true

# 启动新容器
docker run -d \
  --name blog-nginx \
  --restart unless-stopped \
  -p 80:80 \
  -p 443:443 \
  -v "$(pwd)/public:/usr/share/nginx/html:ro" \
  -v "$(pwd)/nginx/default.conf:/etc/nginx/conf.d/default.conf:ro" \
  -v "$(pwd)/nginx/ssl:/etc/nginx/ssl:ro" \
  nginx:alpine

echo "✅ 博客已上线：https://your-server-ip"
```

---

## 八、日常写作工作流

每次写完新文章后，只需两步：

```bash
# 第一步：构建
bash scripts/build.sh

# 第二步：Nginx 自动读取新文件（无需重启容器）
# public/ 目录通过挂载卷共享，构建完成即生效
```

如果修改了 Nginx 配置，需要重载：

```bash
docker exec blog-nginx nginx -s reload
```

---

## 九、常见问题

### 文章不显示？

检查 front matter 中 `draft` 是否为 `false`：

```markdown
---
draft: false   # 必须为 false 才会发布
---
```

### 搜索功能不工作？

确认 `hugo.toml` 中 `outputs` 包含 `JSON`，且 `content/search.md` 存在且 `layout: "search"`。

### 构建时文件权限问题？

Docker 构建时添加 `-u "$(id -u):$(id -g)"` 参数，确保生成的文件属于当前用户。

### 浏览器显示"不安全"？

使用了自签名证书，点击"高级 → 继续访问"即可。如需消除警告，请配置正式域名并申请 Let's Encrypt 证书。

---

## 总结

本博客的整个技术链路非常轻量：

```
写作 (Markdown) → Hugo 构建 (Docker) → 静态文件 (public/) → Nginx 提供服务 (Docker)
```

无数据库、无后端、无复杂运维，适合个人在云服务器上低成本部署。如有问题欢迎留言交流！
