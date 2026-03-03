---
title: "从零搭建个人博客（三）：评论系统配置指南"
date: 2026-03-03
slug: "comments-guide"
weight: 3
draft: false
tags: ["博客", "教程", "Hugo"]
categories: ["技术"]
summary: "详细介绍如何为 Hugo 博客配置 Giscus、Utterances、Waline 等评论系统"
ShowToc: true
comments: true
---

## 评论系统概述

博客现已支持多种评论系统，你可以根据自己的需求选择：

| 评论系统 | 特点 | 推荐指数 | 数据存储 |
|---------|------|---------|---------|
| **Giscus** | 基于 GitHub Discussions，功能强大 | ⭐⭐⭐⭐⭐ | GitHub |
| **Utterances** | 基于 GitHub Issues，轻量简洁 | ⭐⭐⭐⭐ | GitHub |
| **Waline** | 国内开源，功能丰富 | ⭐⭐⭐⭐ | 自建服务器 |
| **Disqus** | 老牌第三方服务 | ⭐⭐⭐ | Disqus 服务器 |

## 推荐：Giscus 评论系统

**Giscus** 是目前最推荐的评论系统，它有以下优势：

✅ 完全免费开源  
✅ 基于 GitHub Discussions  
✅ 支持多语言  
✅ 自动主题切换（深色/浅色）  
✅ 支持 Markdown 和 表情反应  
✅ 无广告，尊重隐私  
✅ 数据存储在你的 GitHub 仓库

### Giscus 配置步骤

#### 1. 准备 GitHub 仓库

首先，你需要一个 GitHub 仓库来存储评论数据：

- 可以是博客源码仓库
- 也可以单独创建一个评论仓库
- 仓库必须是 **公开的（Public）**

#### 2. 启用 GitHub Discussions

在你的 GitHub 仓库中：

1. 进入仓库 Settings
2. 找到 Features 部分
3. 勾选 **Discussions**

#### 3. 安装 Giscus App

访问 [giscus.app](https://github.com/apps/giscus) 并安装到你的仓库：

1. 点击 "Install"
2. 选择你要使用的仓库
3. 授权访问

#### 4. 获取配置参数

访问 [giscus.app](https://giscus.app)，按照页面提示：

1. 填写你的仓库地址（如：`username/blog`）
2. 选择 Discussion 分类（建议新建一个 "Comments" 分类）
3. 页面会自动生成配置代码

你需要获取以下参数：
- `data-repo`: 仓库名称
- `data-repo-id`: 仓库 ID
- `data-category`: 分类名称
- `data-category-id`: 分类 ID

#### 5. 配置 hugo.toml

在 `hugo.toml` 文件的 `[params]` 部分添加：

```toml
[params.giscus]
  enable = true
  repo = "yourusername/your-repo"
  repoId = "R_your_repo_id"
  category = "Comments"
  categoryId = "DIC_your_category_id"
  mapping = "pathname"
  reactionsEnabled = "1"
  emitMetadata = "0"
  inputPosition = "bottom"
  theme = "preferred_color_scheme"
  lang = "zh-CN"
  loading = "lazy"
```

#### 6. 在文章中启用评论

在文章的 Front Matter 中添加：

```yaml
---
title: "你的文章标题"
comments: true
---
```

### Giscus 配置参数说明

| 参数 | 说明 | 可选值 |
|-----|------|--------|
| `repo` | GitHub 仓库 | `username/repo` |
| `repoId` | 仓库 ID | 从 giscus.app 获取 |
| `category` | Discussion 分类 | 自定义名称 |
| `categoryId` | 分类 ID | 从 giscus.app 获取 |
| `mapping` | 页面映射方式 | `pathname`、`url`、`title` 等 |
| `reactionsEnabled` | 启用表情反应 | `0` 或 `1` |
| `inputPosition` | 输入框位置 | `top` 或 `bottom` |
| `theme` | 主题 | `light`、`dark`、`preferred_color_scheme` |
| `lang` | 语言 | `zh-CN`、`en` 等 |

## 备选方案

### Utterances 配置

如果你喜欢更简洁的方案，可以选择 Utterances：

```toml
[params.utterances]
  enable = true
  repo = "yourusername/your-repo"
  issueTerm = "pathname"
  theme = "preferred-color-scheme"
  label = "💬 comment"
```

配置步骤：
1. 安装 [Utterances App](https://github.com/apps/utterances)
2. 在 `hugo.toml` 中添加上述配置
3. 在文章中添加 `comments: true`

### Waline 配置

Waline 是国内开发的评论系统，适合国内用户：

```toml
[params.waline]
  enable = true
  serverURL = "https://your-waline-server.com"
  lang = "zh-CN"
  dark = "auto"
```

配置步骤：
1. 部署 Waline 服务器（可使用 Vercel）
2. 获取服务器地址
3. 在 `hugo.toml` 中添加配置

详细部署教程：[Waline 官方文档](https://waline.js.org/)

### Disqus 配置

如果你已经在使用 Disqus：

```toml
[params.disqus]
  enable = true
  shortname = "your-disqus-shortname"
```

## 全局启用评论

如果你想让所有文章默认启用评论，可以在 `hugo.toml` 中设置：

```toml
[params]
  comments = true
```

这样就不需要在每篇文章中单独添加 `comments: true` 了。

如果某篇文章不想显示评论，可以设置：

```yaml
---
title: "某篇文章"
comments: false
---
```

## 主题自动切换

评论系统会自动跟随博客的深色/浅色主题切换！无需手动配置。

## 常见问题

### Q: 评论加载不出来？

**A:** 检查以下几点：
1. 仓库是否为公开（Public）
2. 是否正确安装了 Giscus/Utterances App
3. 配置参数是否正确（特别是 ID）
4. 浏览器是否屏蔽了第三方 iframe

### Q: 如何自定义评论样式？

**A:** 评论系统会自动适配博客主题。如需深度自定义，可以编辑 `layouts/partials/comments.html` 文件中的 CSS 样式。

### Q: 评论数据如何备份？

**A:** 
- **Giscus/Utterances**: 数据存储在 GitHub，随仓库备份
- **Waline**: 需要备份数据库
- **Disqus**: 可在后台导出数据

### Q: 可以迁移评论数据吗？

**A:** 
- GitHub 系评论系统之间可以迁移（Discussions ↔ Issues）
- 从 Disqus 迁移到 Giscus 需要手动处理

## 总结

推荐配置优先级：
1. 🥇 **Giscus** - 功能最完整，用户体验最佳
2. 🥈 **Utterances** - 轻量简洁，快速部署
3. 🥉 **Waline** - 国内访问友好
4. **Disqus** - 不推荐（广告多、隐私问题）

选择适合你的评论系统，开始与读者互动吧！💬

---

*如果在配置过程中遇到问题，欢迎在下方评论区留言！*
