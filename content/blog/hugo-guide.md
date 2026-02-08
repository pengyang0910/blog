---
title: "Hugo 博客搭建指南"
date: 2026-02-07
draft: false
tags: ["Hugo", "教程", "博客"]
categories: ["技术"]
summary: "详细介绍如何使用 Hugo 和 PaperMod 主题搭建个人博客。"
ShowToc: true
---

## 为什么选择 Hugo？

Hugo 是一个用 Go 语言编写的静态网站生成器，具有以下优势：

### 核心优势

1. **速度极快** ⚡
   - 构建速度比其他静态生成器快数倍
   - 即使上千篇文章也能秒级构建

2. **单文件部署** 📦
   - 无需安装依赖
   - 下载一个二进制文件即可使用

3. **功能丰富** 🎨
   - 内置主题系统
   - 支持多语言
   - 强大的分类和标签系统

4. **社区活跃** 👥
   - 大量优秀主题
   - 丰富的文档和教程

## 快速开始

### 安装 Hugo

```bash
# macOS
brew install hugo

# Ubuntu/Debian
sudo apt install hugo

# 或使用 Docker（推荐）
docker run --rm -v $(pwd):/site hugomods/hugo:latest hugo version
```

### 创建站点

```bash
# 创建新站点
hugo new site myblog
cd myblog

# 添加主题
git submodule add https://github.com/adityatelange/hugo-PaperMod.git themes/PaperMod

# 配置主题
echo "theme = 'PaperMod'" >> hugo.toml
```

### 创建文章

```bash
# 创建新文章
hugo new blog/my-first-post.md

# 本地预览
hugo server -D
```

## 配置优化

在 `hugo.toml` 中添加常用配置：

```toml
baseURL = "https://yourdomain.com/"
languageCode = "zh-cn"
title = "我的博客"
theme = "PaperMod"
paginate = 10
enableEmoji = true

[params]
  defaultTheme = "auto"
  ShowReadingTime = true
  ShowCodeCopyButtons = true
  ShowToc = true
```

## 部署方式

### GitHub Pages

```bash
# 构建站点
hugo

# 推送到 GitHub
git add .
git commit -m "Update blog"
git push origin main
```

### Vercel / Netlify

直接连接 GitHub 仓库，自动部署。

### 自建服务器

使用 Nginx 托管 `public/` 目录。

## 小结

Hugo + PaperMod 是搭建个人博客的绝佳组合，简单、快速、优雅。

Happy blogging! 🎉
