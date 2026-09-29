# 参商Parry 个人博客 — 工程师手册

Hugo + PaperMod 静态站，Docker 构建、Nginx 提供 HTTPS。**内容与配置分离**为两个仓库：

| | 代码仓库（本仓库） | 内容仓库 |
|---|---|---|
| GitHub | `pengyang0910/blog` | `pengyang0910/blog-content` |
| 服务器路径 | `/srv/blog`（root 部署） | `/home/parry/blog`（parry 拥有，写作免 sudo） |
| 内容 | `hugo.toml` `layouts/` `themes/` `assets/` `scripts/` `nginx/` | `content/`（文章 + 每篇 `img/`）、`tools/`（本地可选脚手架） |

- 访问地址：https://pengyang.xyz （公网 IP `47.100.130.28`）
- 本仓库看不到 `content/` 是正常的：它被 `.gitignore` 忽略，构建时由 Docker 只读挂载注入。
- 本地无 Hugo，一切构建走 Docker（镜像 `hugomods/hugo:0.146.0`）。

---

## 1. 博客搭建脚手架

从零到可访问，按顺序执行。

### 1.1 拉取两个仓库

```bash
# 代码仓库(主题 PaperMod 是 git submodule,必须带 --recurse-submodules)
git clone --recurse-submodules git@github.com:pengyang0910/blog.git /srv/blog
# 内容仓库
git clone git@github.com:pengyang0910/blog-content.git /home/parry/blog

# 若 submodule 目录为空,补一句:
git -C /srv/blog submodule update --init --recursive
```

### 1.2 构建站点

```bash
bash /srv/blog/scripts/build.sh
# 输出到 /srv/blog/public/
```

`build.sh` 的核心是双挂载：把代码仓库挂成 Hugo 站点根、把内容仓库的 `content/` 只读覆盖进去。

```bash
docker run --rm \
  -u "$(id -u):$(id -g)" \                    # 必须:避免 public/ 落 root 属主文件
  -v "$PROJECT_ROOT:/site" \                   # 代码仓库
  -v "$BLOG_DATA/content:/site/content:ro" \   # 内容仓库(默认 /home/parry/blog)
  hugomods/hugo:0.146.0 hugo -s /site
```

内容目录不在默认位置时，用环境变量覆盖：`BLOG_DATA=/path/to/data bash scripts/build.sh`。

### 1.3 准备 SSL 证书

```bash
# 自签名(测试/内网,浏览器会告警):输出 nginx/ssl/{cert.pem,key.pem}
bash /srv/blog/scripts/generate-ssl-cert.sh
```

正式证书则直接把文件放到 `nginx/ssl/cert.pem` 与 `nginx/ssl/key.pem`。

### 1.4 部署 Nginx 容器

```bash
bash /srv/blog/scripts/deploy-https.sh
```

该脚本 `docker rm` + `docker run` 重建 `blog-nginx`（非 restart），把 `public/` 只读挂进容器：
- HTTP(80) → 301 跳转 HTTPS(443) → 站点
- **只有改了脚本 / `nginx/` 配置 / 证书才需要重跑**；纯内容或模板改动只需 `build.sh`。

### 1.5 目录结构速查

```
/srv/blog                      # 代码仓库
├── hugo.toml                  # 主配置
├── layouts/                   # 覆盖 PaperMod 的自定义模板
├── assets/css/extended/       # 扩展样式
├── themes/PaperMod/           # git submodule,勿直接改
├── scripts/                   # build.sh / deploy-https.sh / generate-ssl-cert.sh
├── nginx/                     # default.conf / ssl/ / logs/
└── public/                    # 构建产物(gitignore),被 nginx 挂载

/home/parry/blog               # 内容仓库
├── content/                   # 文章,page bundle 结构
│   └── <section>/<slug>/index.md + img/
└── tools/                     # 本地可选脚手架(new-post.sh 等)
```

### 1.6 内容更新流程

文章在**本地写好**再 push 到内容仓库，服务器只负责拉取和构建，不在云上写作。

```bash
# 本地: 编辑 content/<section>/<slug>/index.md(配图上同目录 img/) → git push
# 服务器: 拉取内容仓库 + 重新构建
git -C /home/parry/blog pull
bash /srv/blog/scripts/build.sh
```

- 每篇是 page bundle：`index.md` + 同目录 `img/`，图片用相对路径 `![描述](img/示例.png)` 引用；URL 取 bundle 目录名。
- front matter `draft: true` 的文章不会被构建，发布前改为 `false`。
- `weight` 控制同章节内排序，惯例与文件名/标题前缀保持一致。

### 1.7 本地实时预览

```bash
docker run --rm -it -u "$(id -u):$(id -g)" \
  -v "/srv/blog:/site" \
  -v "/home/parry/blog/content:/site/content:ro" \
  -p 1313:1313 \
  hugomods/hugo:0.146.0 hugo server -s /site --bind 0.0.0.0 --baseURL http://localhost:1313
# 浏览器打开 http://localhost:1313
```

---

## 2. 博客配置说明

改配置基本集中在下面几处；改完 `build.sh` 重新构建即生效（nginx 挂的是 `public/`）。

### 2.1 `hugo.toml`（主配置，最常改）

| 想改什么 | 改哪里 |
|---|---|
| 站点标题 / 描述 / 关键词 / 作者 | `title`、`params.description`、`params.keywords`、`params.author` |
| 外观（亮/暗/自动） | `params.defaultTheme`（`auto`/`light`/`dark`） |
| 文章功能开关（阅读时长、字数、代码复制、上下篇、面包屑、目录等） | `params.Show*` 一系列 |
| 首页/列表显示哪些分区 | `params.mainSections`（默认 `blog`、`knowledge_base`、`projects`） |
| 分页每页条数 | `[pagination] pagerSize` |
| 顶部导航菜单 | `[[menu.main]]` 各项 `name` / `url` / `weight` |
| 社交图标（GitHub/邮箱/RSS） | `[[params.socialIcons]]` |
| 评论系统参数 | `[params.giscus]`（见第 3 节） |
| 站内搜索 Fuse.js 调参 | `[params.fuseOpts]` |
| “建议修改”编辑链接 | `[params.editPost]` |

### 2.2 `layouts/`（覆盖 PaperMod 的模板）

- `layouts/index.html` —— **首页**：顶部个人介绍卡片写死在此，改头像/简介文案动这里。
- `layouts/_default/single.html` —— 文章页三栏布局（左目录 / 正文 / 右栏），含内联 `<style>`。
- `layouts/partials/footer.html` —— **页脚备案信息**（蜀ICP备…号）写死在此。
- `layouts/partials/extend_head.html` / `extend_footer.html` —— 引入 Heti 中文排版、不蒜子统计、扩展 CSS。

### 2.3 `assets/css/extended/`（样式微调）

`custom.css`（覆盖样式主力）、`toc.css`、`heti.css`、`stats.css`。
> 注意：PaperMod 的 `head.html` 会自动打包 `css/extended/*.css`，而 `extend_head.html` 又单独 `<link>` 了一次，目前存在双重加载。

### 2.4 `nginx/`（部署层）

`nginx/default.conf` —— HTTP→HTTPS 跳转与站点根目录；改完需重跑 `deploy-https.sh`。

---

## 3. 评论系统配置（Giscus）

基于 GitHub Discussions。

1. 到 https://giscus.app 填仓库信息，拿到 `repoId` / `categoryId` 等参数。
2. 填进 `hugo.toml` 的 `[params.giscus]`，并置 `enable = true`。
3. **单篇文章要开评论，其 front matter 必须写 `comments: true`** —— `comments.html` 按页面参数判断，全站 `enable` 不够。

详细图文步骤见 [docs/COMMENTS-SETUP.md](docs/COMMENTS-SETUP.md)。

---

## 4. 常用命令

```bash
# —— 更新内容(服务器拉取本地已 push 的内容仓库) ——
git -C /home/parry/blog pull
bash scripts/build.sh

# —— 代码侧(在 /srv/blog) ——
bash scripts/build.sh              # 构建站点 → public/
bash scripts/deploy-https.sh       # 重建 Nginx 容器(改脚本/nginx/证书时才需要)
bash scripts/generate-ssl-cert.sh  # 生成自签名证书

# —— 运维 ——
docker logs -f blog-nginx          # 查看 Nginx 日志
docker stop blog-nginx             # 停止站点
```
