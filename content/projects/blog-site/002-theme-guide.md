---
title: "从零搭建个人博客（二）：PaperMod 主题装扮与定制"
date: 2026-03-03
slug: "theme-guide"
weight: 2
draft: false
tags: ["Hugo", "PaperMod", "博客", "教程"]
categories: ["建站"]
summary: "在博客搭建完成后，进一步定制 PaperMod 主题的外观与功能，包括首页模式、导航菜单、暗色模式、自定义 CSS 及评论系统等。"
ShowToc: true
TocOpen: false
comments: true
---

> 本文是系列第二篇，默认你已按照[第一篇](/blog/blog-setup-guide/)完成了 Hugo + Docker + Nginx 的基础搭建。

---

## 一、首页模式选择

PaperMod 提供两种首页模式，二选一即可。

### 1.1 Profile 模式（个人主页风格）

在 `hugo.toml` 中添加：

```toml
[params.profileMode]
  enabled  = true
  title    = "参商 Parry"
  subtitle = "技术博客 · 知识备忘录"
  imageUrl = "/favicon.svg"
  imageWidth  = 150
  imageHeight = 150

  [[params.profileMode.buttons]]
    name = "📝 博客"
    url  = "/blog"

  [[params.profileMode.buttons]]
    name = "🔍 搜索"
    url  = "/search"
```

### 1.2 List 模式（文章列表风格）

不启用 profileMode，直接在首页显示文章列表，无需额外配置。

---

## 二、导航菜单配置

在 `hugo.toml` 末尾追加，`weight` 越小排越前：

```toml
[[menu.main]]
  name   = "📝 博客"
  url    = "/blog/"
  weight = 10

[[menu.main]]
  name   = "🔍 搜索"
  url    = "/search/"
  weight = 20

[[menu.main]]
  name   = "📂 归档"
  url    = "/archives/"
  weight = 30

[[menu.main]]
  name   = "👤 关于"
  url    = "/about/"
  weight = 40
```

---

## 三、常用外观参数

在 `hugo.toml` 的 `[params]` 块中调整以下字段：

```toml
[params]
  defaultTheme        = "auto"    # auto / light / dark
  ShowReadingTime     = true      # 显示阅读时长
  ShowWordCount       = true      # 显示字数
  ShowCodeCopyButtons = true      # 代码块复制按钮
  ShowPostNavLinks    = true      # 上一篇 / 下一篇
  ShowBreadCrumbs     = true      # 面包屑导航
  ShowToc             = true      # 文章目录
  TocOpen             = false     # 目录默认折叠
  DateFormat          = "2006-01-02"
  ShowLastMod         = true      # 显示最后修改时间
  author              = "参商 Parry"
  description         = "技术博客 · 知识备忘录"
```

---

## 四、暗色模式

`defaultTheme = "auto"` 会跟随系统偏好自动切换，右上角也会出现手动切换按钮。

如果只想固定亮色或暗色：

```toml
defaultTheme = "light"   # 固定亮色
# 或
defaultTheme = "dark"    # 固定暗色
```

---

## 五、自定义 CSS

在 `assets/css/extended/custom.css` 中添加样式（PaperMod 会自动合并此文件）：

```css
/* 示例：正文字体稍大，行高宽松 */
.post-content {
  font-size: 1.05rem;
  line-height: 1.8;
}

/* 示例：代码块圆角 */
.post-content pre {
  border-radius: 8px;
}

/* 示例：标签样式微调 */
.post-tags a {
  border-radius: 4px;
}
```

---

## 六、文章封面图

在文章的 Front Matter 中指定封面：

```markdown
---
title: "文章标题"
cover:
  image: "/images/my-cover.jpg"   # 图片放在 static/images/ 下
  alt:   "封面描述"
  caption: "图片说明"
  relative: false
---
```

在列表页显示封面缩略图，需在 `[params]` 中开启：

```toml
[params]
  ShowCoverImage  = true
  CoverImageList  = true   # 列表页也显示
```

---

## 七、Favicon 配置

将图标文件放入 `static/` 目录：

```
static/
├── favicon.ico
└── favicon.svg
```

PaperMod 默认会读取 `/favicon.ico`，浏览器标签页即可显示图标。

---

## 八、搜索功能

### 8.1 开启 JSON 输出

```toml
[outputs]
  home = ["HTML", "RSS", "JSON"]
```

### 8.2 新建搜索页

`content/search.md`：

```markdown
---
title: "搜索"
layout: "search"
summary: "search"
placeholder: "搜索文章..."
---
```

### 8.3 调整 Fuse.js 灵敏度

```toml
[params.fuseOpts]
  isCaseSensitive = false
  shouldSort      = true
  threshold       = 0.4          # 0 最精确，1 最模糊
  keys            = ["title", "permalink", "summary", "content"]
```

---

## 九、归档页

`content/archives.md`：

```markdown
---
title: "归档"
layout: "archives"
url: "/archives/"
summary: archives
---
```

---

## 十、评论系统（Giscus）

Giscus 基于 GitHub Discussions，免费无广告。

### 10.1 申请配置

1. 前往 [giscus.app](https://giscus.app/zh-CN) 填写仓库信息，获取 `data-repo`、`data-repo-id`、`data-category-id` 等参数。
2. 在对应 GitHub 仓库开启 Discussions 功能。

### 10.2 创建评论模板

新建 `layouts/partials/comments.html`：

```html
<script src="https://giscus.app/client.js"
  data-repo="你的GitHub用户名/仓库名"
  data-repo-id="你的RepoID"
  data-category="Announcements"
  data-category-id="你的CategoryID"
  data-mapping="pathname"
  data-strict="0"
  data-reactions-enabled="1"
  data-emit-metadata="0"
  data-input-position="bottom"
  data-theme="preferred_color_scheme"
  data-lang="zh-CN"
  crossorigin="anonymous"
  async>
</script>
```

### 10.3 在文章中启用评论

在文章 Front Matter 中加入：

```markdown
comments: true
```

或在 `hugo.toml` 全局开启：

```toml
[params]
  comments = true
```

---

## 小结

完成以上配置后，博客在功能和颜值上都能达到不错的水准。后续可以进一步探索：

- 自定义字体（Google Fonts / 本地字体）
- 多语言支持（`i18n/` 目录）
- 社交链接与 RSS 订阅
- 站点统计（Umami / Google Analytics）
