# 1Panel 部署指南

本指南将帮助您使用 1Panel 将 VitePress 网站部署到服务器上。

## 📋 前置准备

### 1. 服务器要求
- Linux 服务器（推荐 Ubuntu 20.04+ 或 CentOS 7+）
- 已安装 1Panel 面板
- 服务器已开放 80/443 端口
- 至少 1GB 内存，2GB 推荐

### 2. 本地准备
- 确保本地代码已提交到 Git 仓库（推荐）
- 或者准备好代码压缩包

---

## 🚀 部署步骤

### 步骤 1：在服务器上安装 Node.js

#### 方法 A：通过 1Panel 应用商店安装

1. 登录 1Panel 面板
2. 进入 **应用商店**
3. 搜索 **Node.js** 并安装（推荐版本 18.x 或更高）
4. 等待安装完成

#### 方法 B：通过终端手动安装

```bash
# 连接到服务器 SSH
ssh root@your-server-ip

# 安装 Node.js 18.x（Ubuntu/Debian）
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# 或使用 nvm 安装（推荐）
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
source ~/.bashrc
nvm install 18
nvm use 18

# 验证安装
node -v
npm -v
```

---

### 步骤 2：上传代码到服务器

#### 方法 A：通过 Git 克隆（推荐）

```bash
# 在服务器上创建网站目录
mkdir -p /www/wwwroot/pathcreator_website
cd /www/wwwroot/pathcreator_website

# 克隆你的 Git 仓库
git clone https://github.com/your-username/your-repo.git .

# 或者如果代码在 web/pathcreator_website 目录
git clone https://github.com/your-username/your-repo.git /tmp/repo
cp -r /tmp/repo/web/pathcreator_website/* /www/wwwroot/pathcreator_website/
```

#### 方法 B：通过 1Panel 文件管理上传

1. 在本地将 `web/pathcreator_website` 目录打包为 zip
2. 登录 1Panel → **文件**
3. 进入 `/www/wwwroot/` 目录
4. 上传 zip 文件并解压
5. 重命名文件夹为 `pathcreator_website`

#### 方法 C：使用 SCP 上传

```bash
# 在本地执行
scp -r web/pathcreator_website root@your-server-ip:/www/wwwroot/
```

---

### 步骤 3：安装依赖并构建网站

```bash
# 进入网站目录
cd /www/wwwroot/pathcreator_website

# 安装依赖
npm install

# 构建网站（生产版本）
npm run docs:build

# 构建完成后，静态文件在 docs/.vitepress/dist 目录
ls -la docs/.vitepress/dist
```

**构建输出位置**：`docs/.vitepress/dist/`

---

### 步骤 4：在 1Panel 中创建网站

#### 4.1 创建网站

1. 登录 1Panel 面板
2. 进入 **网站** → **创建网站**
3. 填写以下信息：
   - **网站域名**：`yourdomain.com`（或 `www.yourdomain.com`）
   - **网站类型**：静态网站
   - **运行目录**：`/www/wwwroot/pathcreator_website/docs/.vitepress/dist`
   - **PHP 版本**：不需要（静态网站）
   - **网站备注**：PathCreator 官网

4. 点击 **确认**

#### 4.2 配置 Nginx（如果需要自定义）

1. 进入 **网站** → 找到你的网站 → **设置**
2. 点击 **配置文件**
3. 可以自定义 Nginx 配置，例如：

```nginx
server {
    listen 80;
    server_name yourdomain.com www.yourdomain.com;
    
    root /www/wwwroot/pathcreator_website/docs/.vitepress/dist;
    index index.html;
    
    # 启用 gzip 压缩
    gzip on;
    gzip_types text/plain text/css application/json application/javascript text/xml application/xml application/xml+rss text/javascript;
    
    # SPA 路由支持（如果使用）
    location / {
        try_files $uri $uri/ /index.html;
    }
    
    # 静态资源缓存
    location ~* \.(jpg|jpeg|png|gif|ico|css|js|svg|woff|woff2)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

---

### 步骤 5：配置 SSL 证书（可选但推荐）

1. 进入 **网站** → 你的网站 → **设置**
2. 点击 **SSL**
3. 选择证书方式：
   - **Let's Encrypt**（免费，推荐）
   - **自签证书**
   - **导入证书**
4. 选择 **Let's Encrypt**：
   - 填写邮箱
   - 选择域名
   - 点击 **申请**
5. 等待证书签发完成
6. 开启 **强制 HTTPS**

---

### 步骤 6：配置域名解析

在你的域名服务商（如阿里云、腾讯云）添加 DNS 记录：

```
类型: A
主机记录: @ (或 www)
记录值: 你的服务器IP
TTL: 600
```

等待 DNS 解析生效（通常几分钟到几小时）。

---

### 步骤 7：测试访问

1. 在浏览器访问：`http://yourdomain.com`
2. 如果配置了 SSL，访问：`https://yourdomain.com`
3. 检查所有页面是否正常显示

---

## 🔄 更新网站

当需要更新网站内容时：

```bash
# 1. 进入网站目录
cd /www/wwwroot/pathcreator_website

# 2. 拉取最新代码（如果使用 Git）
git pull origin main

# 3. 重新安装依赖（如果有新依赖）
npm install

# 4. 重新构建
npm run docs:build

# 构建完成后，网站会自动更新（因为指向的是 dist 目录）
```

---

## 📝 自动化部署脚本

创建部署脚本 `deploy.sh`：

```bash
#!/bin/bash
# 保存为 /www/wwwroot/pathcreator_website/deploy.sh

cd /www/wwwroot/pathcreator_website

# 拉取最新代码
git pull origin main

# 安装依赖
npm install

# 构建网站
npm run docs:build

echo "部署完成！"
```

赋予执行权限：
```bash
chmod +x /www/wwwroot/pathcreator_website/deploy.sh
```

使用：
```bash
./deploy.sh
```

---

## 🐛 常见问题

### 问题 1：构建失败

**原因**：Node.js 版本不兼容

**解决**：
```bash
# 检查 Node.js 版本
node -v

# 如果版本低于 18，升级 Node.js
nvm install 18
nvm use 18
```

### 问题 2：访问 404

**原因**：运行目录配置错误

**解决**：
1. 检查 1Panel 网站设置中的运行目录
2. 确保路径为：`/www/wwwroot/pathcreator_website/docs/.vitepress/dist`
3. 确认 dist 目录存在且有 index.html

### 问题 3：图片不显示

**原因**：路径问题

**解决**：
1. 检查图片是否在 `docs/public/` 目录
2. 确认构建后图片在 `dist/` 目录
3. 检查图片路径是否正确（以 `/` 开头）

### 问题 4：路由刷新 404

**原因**：Nginx 未配置 SPA 支持

**解决**：在 Nginx 配置中添加：
```nginx
location / {
    try_files $uri $uri/ /index.html;
}
```

---

## 📊 性能优化建议

### 1. 启用 Gzip 压缩

在 1Panel 网站设置中启用 Gzip，或在 Nginx 配置中添加（已在上面配置中）

### 2. 配置 CDN

将静态资源（图片、CSS、JS）放到 CDN 上

### 3. 图片优化

- 压缩图片大小
- 使用 WebP 格式
- 添加懒加载

### 4. 缓存策略

已在 Nginx 配置中添加静态资源缓存

---

## 🔐 安全建议

1. **定期更新**：保持 Node.js 和依赖包最新
2. **防火墙**：只开放必要端口（80, 443）
3. **备份**：定期备份网站文件
4. **SSL**：使用 HTTPS 加密传输

---

## 📞 需要帮助？

如果遇到问题，可以：
1. 查看 1Panel 日志：**网站** → **日志**
2. 查看 Nginx 错误日志
3. 检查服务器资源使用情况

---

## ✅ 部署检查清单

- [ ] Node.js 已安装（版本 18+）
- [ ] 代码已上传到服务器
- [ ] 依赖已安装（npm install）
- [ ] 网站已构建（npm run docs:build）
- [ ] 1Panel 网站已创建
- [ ] 运行目录指向 dist 目录
- [ ] SSL 证书已配置（可选）
- [ ] 域名解析已配置
- [ ] 网站可以正常访问
- [ ] 所有页面正常显示
- [ ] 图片正常显示

---

**部署完成后，你的网站就可以通过域名访问了！** 🎉

