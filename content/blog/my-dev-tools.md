---
title: "我的开发工具清单"
date: 2026-02-06
draft: false
tags: ["工具", "效率", "开发环境"]
categories: ["技术"]
summary: "分享我日常使用的开发工具和效率神器。"
ShowToc: true
---

## 编辑器与 IDE

### Visual Studio Code

我的主力编辑器，轻量且强大。

**常用插件：**
- Chinese Language Pack - 中文语言包
- Git Graph - Git 可视化
- Prettier - 代码格式化
- ESLint - 代码检查
- Live Server - 本地服务器
- Docker - 容器管理

**推荐主题：**
- One Dark Pro
- Material Theme
- Dracula

### JetBrains 系列

针对特定语言使用：
- PyCharm - Python 开发
- GoLand - Go 开发
- WebStorm - 前端开发

## 终端工具

### 现代化终端

```bash
# Oh My Zsh - Shell 增强
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# 推荐插件
plugins=(git docker docker-compose kubectl)
```

### 命令行工具

- **exa** - ls 的现代替代品
- **bat** - cat 的增强版
- **fd** - find 的替代品
- **ripgrep** - 更快的 grep
- **fzf** - 模糊搜索工具
- **tldr** - 简化的 man 手册

## 效率工具

### 笔记与文档

- **Obsidian** - Markdown 笔记
- **Notion** - 全能笔记工具
- **Typora** - Markdown 编辑器

### 截图与录屏

- **Snipaste** - 截图 + 贴图
- **OBS Studio** - 录屏直播
- **Asciinema** - 终端录制

### API 开发

- **Postman** - API 测试
- **Insomnia** - REST/GraphQL 客户端
- **HTTPie** - 命令行 HTTP 客户端

## 版本管理

### Git 图形化工具

- **GitKraken** - 跨平台 Git GUI
- **SourceTree** - 免费 Git 客户端
- **Lazygit** - 终端 TUI Git 工具

### Git 配置优化

```bash
# 常用别名
git config --global alias.co checkout
git config --global alias.br branch
git config --global alias.ci commit
git config --global alias.st status
git config --global alias.lg "log --graph --oneline --all"
```

## 容器与虚拟化

- **Docker Desktop** - 容器管理
- **Portainer** - Docker Web UI
- **Kubernetes** - 容器编排

## 浏览器插件

### 开发者工具

- **Vue DevTools / React DevTools** - 前端调试
- **JSON Viewer** - JSON 格式化
- **Wappalyzer** - 技术栈识别
- **Octotree** - GitHub 代码树

### 效率插件

- **Tampermonkey** - 用户脚本
- **Dark Reader** - 深色模式
- **uBlock Origin** - 广告拦截

## 数据库工具

- **DBeaver** - 通用数据库客户端
- **Redis Desktop Manager** - Redis 管理
- **Robo 3T** - MongoDB 客户端

## 总结

工具只是手段，关键是提高效率。选择适合自己的工具，不断优化工作流程。

你有什么推荐的开发工具吗？欢迎留言分享！💬
