# 参商Parry 个人博客备忘录

基于 Hugo + PaperMod 主题构建，Docker + Nginx 部署，支持 HTTPS。

- **公网 IP**：`47.100.130.28`
- **域名**：`pengyang.xyz`
- **访问地址**：https://pengyang.xyz

## 环境依赖

| 依赖 | 说明 |
|------|------|
| Docker | 用于运行 Hugo 构建容器和 Nginx 服务容器 |
| openssl | 用于生成自签名 SSL 证书（可选） |

> 不需要本地安装 Hugo，所有构建操作均通过 Docker 完成。

## 快速开始

### 1. 克隆项目

```bash
git clone --recurse-submodules <your-repo-url>
cd blog
```

> 如果已克隆但未初始化子模块，执行：
> ```bash
> git submodule update --init --recursive
> ```

### 2. 构建静态站点

```bash
bash scripts/build.sh
```

构建完成后，静态文件会输出到 `public/` 目录。

### 3. 准备 SSL 证书

**方式一：使用自签名证书（测试/内网环境）**

```bash
bash scripts/generate-ssl-cert.sh
```

> 浏览器会提示"不安全"，点击"高级 → 继续访问"即可。

**方式二：使用正式证书（生产环境）**

将证书文件放置到以下路径：

```
nginx/ssl/cert.pem   # 证书文件
nginx/ssl/key.pem    # 私钥文件
```

### 4. 部署 Nginx 容器

```bash
bash scripts/deploy-https.sh
```

部署成功后：
- HTTP（80）→ 自动重定向到 HTTPS
- HTTPS（443）→ 博客站点

### 5. 访问博客

```
https://pengyang.xyz
# 或直接通过 IP 访问
https://47.100.130.28
```

---

## 日常写作流程

1. 在 `content/blog/` 下新建 Markdown 文件：
   ```bash
   # 文件名即为 URL slug
   touch content/blog/my-new-post.md
   ```

2. 在文件头部添加 Front Matter：
   ```yaml
   ---
   title: "文章标题"
   date: 2026-03-03
   categories: ["技术"]
   tags: ["Hugo"]
   ---
   ```

3. 重新构建并热更新（重新运行构建 + 重启容器，或仅重建）：
   ```bash
   bash scripts/build.sh
   bash scripts/deploy-https.sh
   ```

---

## 评论系统配置（Giscus）

1. 访问 [https://giscus.app](https://giscus.app) 获取配置参数
2. 编辑 `hugo.toml`，填入 `[params.giscus]` 中对应的值
3. 将 `enable` 改为 `true`

详细配置步骤见 [COMMENTS-SETUP.md](./COMMENTS-SETUP.md)。

---

## 常用命令

```bash
# 构建站点
bash scripts/build.sh

# 部署 / 重启 Nginx 容器
bash scripts/deploy-https.sh

# 生成自签名 SSL 证书
bash scripts/generate-ssl-cert.sh

# 查看 Nginx 容器日志
docker logs -f blog-nginx

# 停止 Nginx 容器
docker stop blog-nginx
```
