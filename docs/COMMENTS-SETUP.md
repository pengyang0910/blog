# 博客评论系统配置指南

## 🎉 评论功能已集成！

你的博客现在已经支持评论功能了！目前显示的是配置提示，需要你完成以下配置步骤来启用真实的评论系统。

## 📋 快速开始（推荐使用 Giscus）

### 第一步：创建或选择 GitHub 仓库

1. 可以使用现有的博客仓库，或创建一个新的评论专用仓库
2. 确保仓库是**公开的（Public）**

### 第二步：启用 GitHub Discussions

1. 进入你的 GitHub 仓库
2. 点击 `Settings` → `Features`
3. 勾选 `Discussions`
4. （可选）在 Discussions 中创建一个 "Comments" 分类

### 第三步：安装 Giscus App

1. 访问 https://github.com/apps/giscus
2. 点击 `Install`
3. 选择要安装的仓库
4. 授权访问

### 第四步：获取配置参数

1. 访问 https://giscus.app
2. 填写你的仓库地址（格式：`username/repository`）
3. 页面会自动检测并显示配置信息
4. 复制以下参数：
   - `data-repo`
   - `data-repo-id`
   - `data-category`
   - `data-category-id`

### 第五步：配置 hugo.toml

打开 `/srv/blog/hugo.toml` 文件，找到 `[params.giscus]` 部分，修改配置：

```toml
[params.giscus]
  enable = true  # ← 改为 true
  repo = "your-username/your-repo"  # ← 填入你的仓库
  repoId = "R_xxxxx"  # ← 填入 repo ID
  category = "Comments"  # ← 填入分类名称
  categoryId = "DIC_xxxxx"  # ← 填入 category ID
  mapping = "pathname"
  reactionsEnabled = "1"
  emitMetadata = "0"
  inputPosition = "bottom"
  theme = "preferred_color_scheme"
  lang = "zh-CN"
  loading = "lazy"
```

### 第六步：重新构建博客

```bash
cd /srv/blog
bash scripts/build.sh
```

### 第七步：部署并测试

重新部署后，访问任何一篇启用了 `comments: true` 的文章，就能看到评论框了！

## 📝 已启用评论的文章

目前以下文章已开启评论功能：

- ✅ `content/blog/hello.md` - Hello Blog
- ✅ `content/blog/hugo-guide.md` - Hugo 博客搭建指南
- ✅ `content/blog/my-dev-tools.md` - 我的开发工具清单
- ✅ `content/blog/comments-guide.md` - 如何配置博客评论系统

## 🔧 为文章启用评论

在文章的 Front Matter 中添加：

```yaml
---
title: "文章标题"
comments: true  # ← 添加这一行
---
```

## 🌟 支持的评论系统

除了 Giscus，还支持以下评论系统：

### Utterances（轻量级选择）
基于 GitHub Issues，配置更简单

### Waline（国内友好）
支持匿名评论，可自行部署

### Disqus（不推荐）
老牌服务，但有广告和隐私问题

详细配置方法请查看：`content/blog/comments-guide.md`

## ❓ 常见问题

### Q: 为什么评论显示"尚未配置"？
**A:** 需要在 `hugo.toml` 中启用评论系统（设置 `enable = true`）并填写正确的配置参数。

### Q: 评论加载很慢或加载不出来？
**A:** 检查：
1. GitHub 是否能正常访问
2. 仓库是否为公开
3. Giscus App 是否已安装
4. 配置参数是否正确

### Q: 可以全局启用评论吗？
**A:** 可以！在 `hugo.toml` 的 `[params]` 部分添加：
```toml
[params]
  comments = true
```
这样所有文章都会默认显示评论区。

### Q: 评论数据存储在哪里？
**A:** Giscus 的评论数据存储在你的 GitHub Discussions 中，完全由你控制。

## 🎨 样式定制

评论系统会自动适配博客的深色/浅色主题。如需自定义样式，可以编辑：
`layouts/partials/comments.html`

## 📚 相关文档

- Giscus 官网：https://giscus.app
- Giscus 仓库：https://github.com/giscus/giscus
- 详细教程：查看博客文章《如何配置博客评论系统》

---

**祝你使用愉快！如有问题，欢迎在评论区交流！** 💬
