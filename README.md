# 进销存管理系统

> 轻量、可扩展的企业进销存管理系统，覆盖采购入库 → 销售出库 → 库存盘点 → 库存调拨 → 统计报表核心业务全链路。支持 PC 管理后台 + 微信小程序双端操作。

---

# 一、使用教程

## 1.1 系统简介

系统分为两个操作端：

| 端 | 用户 | 场景 |
|----|------|------|
| **PC 管理后台**（浏览器访问） | 管理员、仓库主管 | 商品管理、单据审核、报表导出 |
| **微信小程序** | 仓库员、销售员 | 手持扫码、现场盘点、移动出库 |

默认账号（首次登录后请修改密码）：

| 账号 | 密码 | 角色 | 权限 |
|------|------|------|------|
| admin | 123456 | 管理员 | 全部功能 |
| warehouse | 123456 | 仓库员 | 无采购价查看、无采购模块 |

---

## 1.2 新手入门（5 步上手）

### 第 1 步：登录改密

打开 PC 管理后台，用管理员账号登录，进入「系统管理 → 个人设置」修改密码。

### 第 2 步：建立仓库结构

进入「仓库管理」，按实际场地建仓库层级：

```
总仓（1级）
├── A区（2级）
│   ├── A-01货架（3级）
│   │   ├── 一层（4级）
│   │   └── 二层（4级）
│   └── A-02货架（3级）
└── B区（2级）
```

**操作**：先建 1 级节点（如"总仓"），再点击该节点进入下级，逐层往下建。建到最末级（4 级）就是实际存放商品的位置。

### 第 3 步：录入商品

进入「商品管理」，点击新增商品，填写名称、规格、单位、分类、采购价、销售价等。

> ⚠️ 采购价仅管理员可见，仓库员在小程序和 PC 端都看不到。

### 第 4 步：首次入库

进入「采购管理」→ 新增采购单 → 选择供应商、仓库、商品 → 提交 → 管理员审核通过 → 商品入库，库存生成。

### 第 5 步：日常操作

入库后即可进行销售出库、库存盘点、库存调拨等日常操作。

---

## 1.3 各功能流程详解

### 采购入库流程

```
操作人          步骤                    状态变化
─────────────────────────────────────────────────
管理员    ① 新建采购单（选供应商、仓库、商品）   草稿
管理员    ② 提交审核                          待审核
管理员    ③ 审核通过                          已入库
```

- **批次号**：每次入库自动生成批次号 `IN20240610`，同一天多次入库加序号 `IN20240610-2`
- **成本价**：每个批次的成本价 = 入库时的采购单价，各批次独立
- **取消**：已入库的单据不可取消，需使用「作废」功能（作废不影响已有库存）
- 入库后商品库存增加，可在「库存查询」中实时查看

### 销售出库流程

```
操作人          步骤                    状态变化
─────────────────────────────────────────────────
仓库员    ① 新建销售单（选客户、仓库、商品）   草稿
仓库员    ② 提交审核                          待审核
管理员    ③ 审核通过                          已出库
```

- **批次选择**：出库时选择仓库后会列出各批次，可指定批次出库；不指定则按先进先出自动扣减
- **扫码出库**：小程序支持扫码枪扫商品条码快速选择商品
- **库存不足**：出库数量超过库存时审核会失败，提示库存不足

### 库存盘点流程

```
操作人          步骤                    状态变化
─────────────────────────────────────────────────
仓库员    ① 创建盘点单（选仓库）                草稿
仓库员    ② 添加盘点商品，录入实际数量          草稿
仓库员    ③ 提交审核                          待审核
管理员    ④ 审核通过（自动调整库存）            已盘点
```

- **按批次盘点**：每个入库批次单独一行，各自填写实盘数量，各自调整差异
- **盘盈盘亏**：实盘数 > 账面数 = 盘盈（库存增加），反之 = 盘亏（库存减少）
- 盘点单会自动加载该仓库所有有库存的商品及其批次

### 库存调拨流程

```
操作人          步骤                    状态变化
─────────────────────────────────────────────────
仓库员    ① 创建调拨单（选源仓库、目标仓库、商品） 草稿
仓库员    ② 提交审核                          待审核
管理员    ③ 审核通过                          已调拨
```

- 源仓库库存减少，目标仓库库存增加
- **成本价**：调拨到目标仓库的商品沿用源仓库批次的成本价
- **批次**：调拨生成新批次 `TR20240610`，保留源批次信息以便追溯
- **指定批次**：调拨时可指定源仓库的具体批次

### 审批管理（管理员专用）

进入「审批管理」页面，集中查看所有待审核单据：
- **采购单**：审核通过 → 入库；驳回 → 退回草稿
- **销售单**：审核通过 → 出库；驳回 → 退回草稿
- **盘点单**：审核通过 → 自动调整库存差异
- **调拨单**：审核通过 → 执行调拨

每个标签页有数量角标，支持按单号搜索。

### 库存查询

- **树形视图**：按仓库层级展开，查看每个仓库节点下的商品和数量
- **搜索模式**：输入商品名称或编码，跨仓库搜索该商品在各仓库的分布
- **库存流水**：记录每次库存变动（入库/出库/调拨/盘点），可追溯历史

---

## 1.4 权限说明

| 功能 | 管理员 | 仓库员 |
|------|:---:|:---:|
| 商品管理（增删改查） | ✓ | ✓ |
| 查看采购价 | ✓ | ✗ |
| 采购管理（创建/查看/审核） | ✓ | ✗ |
| 销售管理（创建/查看/审核） | ✓ | ✓ |
| 库存盘点（创建/查看/审核） | ✓ | ✓ |
| 库存调拨（创建/查看/审核） | ✓ | ✓ |
| 库存查询 | ✓ | ✓（看不到成本价）|
| 审批管理 | ✓ | ✗ |
| 数据导出 | ✓ | ✗ |

---

## 1.5 小程序操作要点

1. **商品选择**：出库/调拨时，选择仓库后会列出该仓所有库存批次，每行显示批次号和入库日期
2. **扫码功能**：点击扫描按钮可扫商品条码，自动匹配仓库库存中的商品
3. **审批**：小程序端管理员可审核单据（需要管理员账号登录）
4. **库存查询**：支持按仓库树浏览和按商品名搜索两种模式
5. **图片上传**：商品详情页支持拍照或从相册上传商品图片

---

# 二、系统架构

```
┌──────────────────────────────────────────────────┐
│                 微信小程序 (UniApp)               │
│         仓库员/销售员手持端操作                     │
└────────────────────┬─────────────────────────────┘
                     │ HTTPS
┌────────────────────▼─────────────────────────────┐
│              Nginx (反向代理 + 静态文件)             │
│     ┌────────────────────────────────────────┐     │
│     │   PC 管理后台 (Vue 3 + Element Plus)     │     │
│     │   管理员/仓库员 Web 操作                  │     │
│     └────────────────────────────────────────┘     │
└────────────────────┬─────────────────────────────┘
                     │ /api/* → 8080
┌────────────────────▼─────────────────────────────┐
│           后端 API (Spring Boot 3.x)               │
│    Sa-Token + JWT 认证  │  AOP 操作日志审计          │
└────────────────────┬─────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────┐
│               MySQL 8.0 (21 张表)                  │
└──────────────────────────────────────────────────┘
```

## 技术栈

| 层级 | 技术 | 版本 |
|------|------|------|
| 后端 | Java + Spring Boot + MyBatis-Plus | 17 / 3.2.5 / 3.5.5 |
| 认证 | Sa-Token + JWT | 1.39.0 |
| 数据库 | MySQL | 8.0+ |
| PC 后台 | Vue 3 + TypeScript + Element Plus | 3.4 |
| 小程序 | UniApp + Vue 3 | 3.x |
| 部署 | Docker + Docker Compose | - |

---

## 三、环境准备

### 1.1 服务器要求

| 配置 | 最低要求 | 推荐配置 |
|------|----------|----------|
| CPU | 2 核 | 4 核 |
| 内存 | 4 GB | 8 GB |
| 硬盘 | 40 GB | 100 GB SSD |
| 操作系统 | CentOS 7+ / Ubuntu 20.04+ | Ubuntu 22.04 LTS |

### 1.2 安装 Docker

```bash
# Ubuntu / Debian
curl -fsSL https://get.docker.com | sh
sudo systemctl start docker
sudo systemctl enable docker

# 验证安装
docker --version
docker compose version
```

### 1.3 安装 Git

```bash
sudo apt update && sudo apt install git -y
```

---

## 四、获取代码

```bash
# 克隆项目
git clone <仓库地址> /opt/inventory
cd /opt/inventory

# 查看项目结构
ls -la
```

项目结构：

```
inventory/
├── inventory-server/        # 后端 (Spring Boot)
│   ├── Dockerfile
│   └── pom.xml
├── inventory-admin/         # PC 管理后台 (Vue 3)
│   ├── Dockerfile
│   └── nginx.conf
├── inventory-miniapp/       # 微信小程序 (UniApp)
├── sql/                     # 数据库初始化脚本
│   └── 01-schema.sql
├── docker-compose.yml       # Docker 编排配置
└── README.md
```

---

## 五、配置环境变量

### 3.1 创建环境变量文件

```bash
cat > .env << 'EOF'
# ============ 数据库配置 ============
MYSQL_ROOT_PASSWORD=your_strong_password_here
MYSQL_DATABASE=inventory

# ============ 后端配置 ============
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=your_strong_password_here
APP_UPLOAD_BASE_PATH=/app/uploads

# ============ JWT 密钥 ============
# 生成随机密钥：openssl rand -base64 48
SA_TOKEN_JWT_SECRET=your_random_jwt_secret_at_least_32_chars
EOF
```

### 3.2 修改配置

用文本编辑器打开 `.env`，修改以下配置：

```bash
vim .env
# 或
nano .env
```

**必须修改的配置项：**

| 配置项 | 说明 | 示例 |
|--------|------|------|
| `MYSQL_ROOT_PASSWORD` | MySQL root 密码 | `MyStr0ng!Pass#2024` |
| `SPRING_DATASOURCE_PASSWORD` | 后端连接数据库密码（与上方一致） | `MyStr0ng!Pass#2024` |
| `SA_TOKEN_JWT_SECRET` | JWT 签名密钥（≥32位随机字符串） | `openssl rand -base64 48` 生成 |

---

## 六、Docker 部署

### 4.1 修改 docker-compose.yml

确保 `docker-compose.yml` 使用环境变量：

```yaml
version: '3.8'

services:
  mysql:
    image: mysql:8.0
    container_name: inventory-mysql
    restart: unless-stopped
    environment:
      MYSQL_ROOT_PASSWORD: ${MYSQL_ROOT_PASSWORD}
      MYSQL_DATABASE: ${MYSQL_DATABASE}
    ports:
      - "3307:3306"
    volumes:
      - ./data/mysql:/var/lib/mysql
      - ./sql/01-schema.sql:/docker-entrypoint-initdb.d/01-schema.sql
    command: ["--character-set-server=utf8mb4", "--collation-server=utf8mb4_unicode_ci", "--skip-character-set-client-handshake"]

  server:
    build: ./inventory-server
    container_name: inventory-server
    restart: unless-stopped
    depends_on:
      - mysql
    environment:
      MYSQL_ADDR: mysql
      SPRING_DATASOURCE_USERNAME: ${SPRING_DATASOURCE_USERNAME}
      SPRING_DATASOURCE_PASSWORD: ${SPRING_DATASOURCE_PASSWORD}
      APP_UPLOAD_BASE_PATH: ${APP_UPLOAD_BASE_PATH}
      SA_TOKEN_JWT_SECRET: ${SA_TOKEN_JWT_SECRET}
    volumes:
      - ./data/uploads:/app/uploads
    ports:
      - "8080:8080"

  admin:
    build: ./inventory-admin
    container_name: inventory-admin
    restart: unless-stopped
    depends_on:
      - server
    ports:
      - "80:80"
```

### 4.2 创建数据目录

```bash
mkdir -p data/mysql data/uploads
```

### 4.3 构建并启动

```bash
# 构建镜像
docker compose build

# 启动服务
docker compose up -d

# 查看运行状态
docker compose ps

# 查看日志
docker compose logs -f
```

### 4.4 验证服务

```bash
# 检查容器状态
docker compose ps

# 应该看到 3 个容器运行中：
# inventory-mysql
# inventory-server
# inventory-admin

# 测试后端 API
curl http://localhost:8080/api/v1/health

# 测试前端页面
curl -I http://localhost
```

---

## 七、手动部署（不用 Docker）

### 5.1 安装 Java 17

```bash
# Ubuntu
sudo apt install openjdk-17-jdk -y

# 验证
java -version
```

### 5.2 安装 MySQL 8.0

```bash
# Ubuntu
sudo apt install mysql-server -y
sudo systemctl start mysql
sudo systemctl enable mysql

# 安全配置
sudo mysql_secure_installation
```

### 5.3 初始化数据库

```bash
# 登录 MySQL
mysql -u root -p

# 创建数据库和用户
CREATE DATABASE inventory CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'inventory'@'localhost' IDENTIFIED BY 'your_password';
GRANT ALL PRIVILEGES ON inventory.* TO 'inventory'@'localhost';
FLUSH PRIVILEGES;
EXIT;

# 导入表结构
mysql -u inventory -p inventory < sql/01-schema.sql
```

### 5.4 配置后端

创建生产配置文件：

```bash
cat > inventory-server/src/main/resources/application-prod.yml << 'EOF'
server:
  port: 8080

spring:
  datasource:
    url: jdbc:mysql://localhost:3306/inventory?useUnicode=true&characterEncoding=utf-8&serverTimezone=Asia/Shanghai
    username: inventory
    password: your_password
    driver-class-name: com.mysql.cj.jdbc.Driver

sa-token:
  jwt-secret-key: your_random_jwt_secret_at_least_32_chars
  timeout: 86400
  active-timeout: 1800

app:
  upload-base-path: /data/inventory/uploads

mybatis-plus:
  configuration:
    log-impl: org.apache.ibatis.logging.nologging.NoLoggingImpl

logging:
  level:
    com.inventory: warn
EOF
```

### 5.5 编译并启动后端

```bash
cd inventory-server

# 编译
mvn clean package -DskipTests

# 创建上传目录
mkdir -p /data/inventory/uploads/images

# 启动（后台运行）
nohup java -jar target/inventory-server-*.jar --spring.profiles.active=prod > /var/log/inventory-server.log 2>&1 &

# 查看日志
tail -f /var/log/inventory-server.log
```

### 5.6 安装 Node.js 并编译前端

```bash
# 安装 Node.js 18+
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs -y

# 编译前端
cd inventory-admin
npm install
npm run build

# 复制到 Nginx 目录
sudo cp -r dist/* /var/www/html/
```

### 5.7 配置 Nginx

```bash
sudo vim /etc/nginx/sites-available/inventory
```

写入以下配置：

```nginx
server {
    listen 80;
    server_name your_domain.com;  # 替换为你的域名或 IP

    client_max_body_size 10m;

    # 前端静态文件
    location / {
        root /var/www/html;
        index index.html;
        try_files $uri $uri/ /index.html;
    }

    # 后端 API 代理
    location /api/ {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # 文件上传代理
    location /uploads/ {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
    }
}
```

启用配置：

```bash
sudo ln -s /etc/nginx/sites-available/inventory /etc/nginx/sites-enabled/
sudo nginx -t
sudo systemctl reload nginx
```

---

## 八、HTTPS 配置（推荐）

### 6.1 使用 Let's Encrypt 免费证书

```bash
# 安装 Certbot
sudo apt install certbot python3-certbot-nginx -y

# 申请证书
sudo certbot --nginx -d your_domain.com

# 自动续期测试
sudo certbot renew --dry-run
```

### 6.2 手动配置 SSL

```nginx
server {
    listen 443 ssl;
    server_name your_domain.com;

    ssl_certificate /etc/letsencrypt/live/your_domain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/your_domain.com/privkey.pem;

    # ... 其他配置同上
}

server {
    listen 80;
    server_name your_domain.com;
    return 301 https://$server_name$request_uri;
}
```

---

## 九、小程序配置

### 7.1 修改 API 地址

编辑 `inventory-miniapp/src/api/request.js`：

```javascript
// 修改为生产环境域名（必须是 HTTPS）
const BASE_URL = 'https://your_domain.com/api/v1'
```

### 7.2 编译小程序

```bash
cd inventory-miniapp
npm install
npm run build:mp-weixin
```

### 7.3 发布小程序

1. 用微信开发者工具打开 `dist/build/mp-weixin/`
2. 上传代码
3. 在微信公众平台提交审核

**小程序要求：**
- 已备案域名
- HTTPS 证书
- 在小程序后台配置合法域名白名单

---

## 十、数据库备份

### 8.1 创建备份脚本

```bash
cat > /opt/inventory/backup.sh << 'EOF'
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/opt/inventory/backups"

mkdir -p $BACKUP_DIR

# Docker 方式备份
docker exec inventory-mysql mysqldump -u root -p${MYSQL_ROOT_PASSWORD} inventory > $BACKUP_DIR/inventory_$DATE.sql

# 保留最近 30 天备份
find $BACKUP_DIR -name "*.sql" -mtime +30 -delete

echo "Backup completed: inventory_$DATE.sql"
EOF

chmod +x /opt/inventory/backup.sh
```

### 8.2 设置定时任务

```bash
# 编辑 crontab
crontab -e

# 添加每天凌晨 3 点备份
0 3 * * * cd /opt/inventory && ./backup.sh >> /var/log/inventory-backup.log 2>&1
```

---

## 十一、运维管理

### 9.1 常用命令

```bash
# 进入项目目录
cd /opt/inventory

# 启动服务
docker compose up -d

# 停止服务
docker compose down

# 重启服务
docker compose restart

# 查看日志
docker compose logs -f
docker compose logs -f server    # 只看后端日志

# 进入容器
docker exec -it inventory-server bash
docker exec -it inventory-mysql mysql -u root -p

# 更新代码并重新部署
git pull
docker compose down
docker compose build
docker compose up -d
```

### 9.2 监控检查

```bash
# 检查容器状态
docker compose ps

# 检查资源占用
docker stats

# 检查磁盘空间
df -h

# 检查数据库连接
docker exec inventory-mysql mysqladmin -u root -p status
```

### 9.3 日志位置

| 服务 | 日志命令 |
|------|----------|
| 所有服务 | `docker compose logs -f` |
| 后端 | `docker compose logs -f server` |
| 数据库 | `docker compose logs -f mysql` |
| Nginx | `docker compose logs -f admin` |

---

## 十二、故障排查

### 10.1 服务无法启动

```bash
# 查看详细日志
docker compose logs

# 检查端口占用
sudo lsof -i :80
sudo lsof -i :8080
sudo lsof -i :3307

# 检查配置文件语法
docker compose config
```

### 10.2 数据库连接失败

```bash
# 检查 MySQL 容器状态
docker compose ps mysql

# 测试数据库连接
docker exec -it inventory-mysql mysql -u root -p

# 查看数据库日志
docker compose logs mysql
```

### 10.3 前端无法访问后端

```bash
# 检查后端是否正常
curl http://localhost:8080/api/v1/health

# 检查 Nginx 配置
docker exec inventory-admin nginx -t

# 查看 Nginx 日志
docker compose logs admin
```

---

## 生产检查清单

部署完成后，请逐项确认：

### 基础环境
- [ ] Docker 和 Docker Compose 已安装
- [ ] 服务器防火墙已开放 80、443 端口
- [ ] 域名已解析到服务器 IP

### 数据库安全
- [ ] MySQL root 密码已修改为强密码
- [ ] 数据库已配置定时备份
- [ ] 备份文件可正常恢复

### 应用安全
- [ ] JWT 密钥已替换为随机字符串（≥32位）
- [ ] 已配置 HTTPS
- [ ] 小程序域名白名单已配置

### 功能验证
- [ ] PC 后台可正常访问
- [ ] 登录功能正常（默认账号：admin / 123456）
- [ ] 商品图片上传正常
- [ ] 小程序可正常连接后端

### 运维准备
- [ ] 日志监控已配置
- [ ] 备份定时任务已设置
- [ ] 运维文档已交接

---

## 默认账号

| 账号 | 密码 | 角色 |
|------|------|------|
| admin | 123456 | 系统管理员 |
| warehouse | 123456 | 仓库管理员 |
| sales | 123456 | 销售员 |

**首次登录后请立即修改默认密码！**

---

## License

