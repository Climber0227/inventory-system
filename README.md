# 进销存管理系统

> 轻量、可扩展的企业进销存管理系统，覆盖采购入库 → 销售出库 → 库存盘点 → 库存调拨 → 统计报表核心业务全链路。支持 PC 管理后台 + 微信小程序双端操作。

## 系统架构

```
┌──────────────────────────────────────────────────┐
│                 微信小程序 (UniApp)               │
│         仓库员/销售员手持端操作                     │
└────────────────────┬─────────────────────────────┘
                     │ HTTP/JSON
┌────────────────────▼─────────────────────────────┐
│              Nginx (反向代理 + 静态文件)             │
│     ┌────────────────────────────────────────┐     │
│     │   PC 管理后台 (Vue 3 + Element Plus)     │     │
│     │   管理员/仓库员 Web 操作                  │     │
│     └────────────────────────────────────────┘     │
└────────────────────┬─────────────────────────────┘
                     │ /api/* → 8080  /uploads/* → 8080
┌────────────────────▼─────────────────────────────┐
│           后端 API (Spring Boot 3.x)               │
│    Sa-Token + JWT 认证  │  AOP 操作日志审计          │
│    商品图片上传 → /uploads/images/               │
└────────────────────┬─────────────────────────────┘
                     │
┌────────────────────▼─────────────────────────────┐
│               MySQL 8.0 (21 张表)                  │
│         商品、库存、单据、权限完整设计                │
└──────────────────────────────────────────────────┘
```

## 技术栈

| 层级 | 技术 | 用途 |
|------|------|------|
| **后端** | Java 17 + Spring Boot 3.2.5 + MyBatis-Plus 3.5.5 | RESTful API |
| **认证** | Sa-Token 1.37 + JWT | 无状态登录鉴权，无需 Redis |
| **数据库** | MySQL 8.0 | 21 张业务表，完整索引设计 |
| **PC 后台** | Vue 3.4 + TypeScript + Element Plus + Pinia | 管理员操作界面 |
| **小程序** | UniApp 3.x + Vue 3 + Pinia + Axios | 微信小程序手持端 |
| **报表** | ECharts 6 + vue-echarts | 数据可视化仪表盘 |
| **文档** | Knife4j (Swagger) | 在线 API 接口文档 |
| **工具** | Hutool 5.8 / EasyExcel 3.3 / ZXing | 工具库 / Excel / 条码生成 |
| **部署** | Docker + Docker Compose | 容器化部署 |

## 功能概览

### 基础资料管理
- **商品管理** — CRUD、图片上传、条码生成（单个/批量 ZIP 下载）、Excel 导出、批量启用/停用
- **商品分类** — 树形结构多级分类、父子级关联、作废保护（有商品引用的分类禁止删除）
- **供应商/客户管理** — CRUD、批量作废、Excel 导出
- **仓库/库位管理** — 多仓库多库位、容量设置
- **自动编码** — 商品/仓库/客户/供应商编码自动生成（前缀 + yyyyMMdd + 流水号），禁止手动输入

### 采购入库
- 新建入库单（含明细）、草稿保存、提交入库（库存增加）、取消（回滚库存）、作废
- 状态流转：草稿 → 已入库 → 已取消 → 已作废
- 支持扫描商品条码快速录入

### 销售出库
- 新建出库单（含明细）、草稿保存、提交出库（FIFO 扣减库存）
- 库存不足拦截、安全库存预警提醒
- 出库取消自动回滚库存

### 库存管理
- **库存查询** — 按商品/仓库多维度查询，可用/锁定/在途库存区分，预警变色显示
- **库存流水** — 按商品/仓库/类型/单号/操作人/时间全量追溯
- **安全库存预警** — 低于阈值标红提醒
- **库存盘点** — 全盘/抽盘、差异计算、审核确认、盈亏调整
- **库存调拨** — 跨仓库调拨、源仓扣减/目标仓增加、禁止同仓库调拨

### 统计报表
- **工作台仪表盘** — 商品总数、仓库数、今日/本月单据量、预警数
- **入库/出库汇总** — 近 N 天趋势分析（单数、数量、金额）
- **库存预警** — 低于安全库存的商品列表
- **库存周转率** — 商品周转排行分析

### 系统管理
- **用户管理** — CRUD、账号状态管理
- **角色管理** — 角色定义与权限分配
- **操作日志** — AOP 切面自动记录写操作，按模块/日期筛选审计
- **系统配置** — 编码规则、安全库存阈值等全局参数
- **已作废列表** — 所有作废数据分类展示（含作废时间、原因），支持恢复

## 生产部署

### 环境要求

| 组件 | 版本 | 说明 |
|------|------|------|
| JDK | 17+ | Spring Boot 3.2 要求 |
| MySQL | 8.0+ | 数据库 |
| Nginx | 1.20+ | 反向代理 + 静态文件服务 |
| 服务器 | 2 核 4G 起 | 4 核 8G 推荐 |

### 方式一：Docker 部署（推荐）

```bash
# 1. 修改 docker-compose.yml 中的默认密码
# 2. 一键启动
docker-compose up -d

# 3. 查看运行状态
docker-compose ps
docker-compose logs -f
```

访问地址：

| 服务 | 地址 | 说明 |
|------|------|------|
| 管理后台 | http://服务器IP | 通过 Nginx 访问 |
| 后端 API | http://服务器IP:8080 | 后端服务 |
| Swagger 文档 | http://服务器IP:8080/doc.html | API 接口文档 |
| MySQL 外部连接 | 服务器IP:3307 | 数据库管理工具用 |

### 方式二：手动部署

#### 1. 初始化数据库

```bash
mysql -u root -p < sql/01-schema.sql
```

生产环境建议创建独立数据库账号：

```sql
CREATE USER 'inventory'@'%' IDENTIFIED BY '随机密码';
GRANT ALL PRIVILEGES ON inventory.* TO 'inventory'@'%';
FLUSH PRIVILEGES;
```

#### 2. 配置生产参数

复制并编辑 `application-prod.yml`（需自行创建）：

```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/inventory?useUnicode=true&characterEncoding=utf-8&serverTimezone=Asia/Shanghai&nullCatalogMeansCurrent=true
    username: inventory       # 专用账号，不使用 root
    password: 你的数据库密码

sa-token:
  jwt-secret-key: 替换为随机字符串，至少32位

app:
  upload-base-path: /data/inventory/uploads   # 上传文件存储路径

mybatis-plus:
  configuration:
    log-impl: org.apache.ibatis.logging.nologging.NoLoggingImpl  # 关闭 SQL 日志
```

#### 3. 创建上传目录

```bash
mkdir -p /data/inventory/uploads/images
```

商品图片上传后存储在 `{upload-base-path}/images/` 目录，通过 `http://服务器IP/uploads/images/{文件名}` 访问。后端通过静态资源映射（`WebMvcConfig.java`）将 `/uploads/**` 路径指向文件系统目录。

#### 4. 编译并启动后端

```bash
cd inventory-server
mvn clean package -DskipTests
java -jar target/inventory-server-*.jar --spring.profiles.active=prod
```

#### 5. 编译并部署前端

```bash
cd inventory-admin
npm install
npm run build        # 产物在 dist/
```

将 `dist/` 目录上传到服务器，配置 Nginx：

```nginx
server {
    listen 80;
    server_name 你的域名或IP;

    location / {
        root /data/inventory/admin;
        index index.html;
        try_files $uri $uri/ /index.html;   # Vue 路由支持
    }

    location /api/ {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }

    # 商品图片访问
    location /uploads/ {
        proxy_pass http://127.0.0.1:8080;
        proxy_set_header Host $host;
    }
}
```

#### 6. 数据库定时备份

```bash
# /data/inventory/backup.sh
#!/bin/bash
DATE=$(date +%Y%m%d)
mysqldump -u inventory -p密码 inventory > /data/inventory/backup/inventory_$DATE.sql
find /data/inventory/backup -mtime +30 -name "*.sql" -delete
```

```bash
# crontab 每天凌晨 3 点执行
0 3 * * * bash /data/inventory/backup.sh
```

### 小程序部署说明

1. 修改 `inventory-miniapp/src/api/request.js` 中的 `BASE_URL` 为生产环境地址
2. 确保后端地址**公网可访问**，小程序不支持内网 IP
3. 图片 URL 需要后端域名可被小程序访问，注意 HTTPS 要求（微信小程序生产环境要求已备案域名 + HTTPS）

```bash
cd inventory-miniapp
npm install
npm run build:mp-weixin
```

用微信开发者工具打开 `dist/build/mp-weixin/`，上传审核发布。

### 生产检查清单

- [ ] 数据库创建专用账号（不使用 root）
- [ ] JWT 密钥替换为随机字符串（≥32 位）
- [ ] 数据库密码通过启动参数或环境变量传入，不硬编码
- [ ] MyBatis SQL 日志关闭（`NoLoggingImpl`）
- [ ] 上传目录已创建且有写入权限
- [ ] Nginx 配置了 `/uploads/` 反向代理
- [ ] 数据库定时备份已配置
- [ ] 小程序 BASE_URL 已改为生产地址
- [ ] 生产环境建议配置 HTTPS

## 测试账号

| 账号 | 密码 | 角色 | 说明 |
|------|------|------|------|
| admin | 123456 | 系统管理员 | 全功能权限 |
| warehouse | 123456 | 仓库管理员 | 出入库、盘点 |
| sales | 123456 | 销售员 | 出库、查库存 |

## 开发环境启动

```bash
# 1. 导入数据库
mysql -u root -p < sql/01-schema.sql

# 2. 启动后端（开发模式，自动热重载）
cd inventory-server
mvn spring-boot:run

# 3. 启动管理后台（Vite 开发服务器）
cd inventory-admin
npm install
npm run dev

# 4. 编译小程序
cd inventory-miniapp
npm install
npm run dev:mp-weixin    # 产物在 dist/dev/mp-weixin/
```

## 项目结构

```
inventory/
├── inventory-server/        # 后端服务 (Spring Boot 3.2)
│   ├── src/main/java/       # 102 个 Java 文件：Controller/Service/Mapper/Entity
│   ├── src/main/resources/  # 配置：application.yml、Mapper XML
│   ├── Dockerfile
│   └── pom.xml
├── inventory-admin/         # PC 管理后台 (Vue 3 + Element Plus)
│   ├── src/                 # 27 个页面，20+ 路由
│   ├── Dockerfile
│   └── nginx.conf
├── inventory-miniapp/       # 微信小程序 (UniApp 3.x)
│   ├── src/                 # 19 个页面，5 个 Tab 导航
│   └── pages.json
├── sql/                     # 数据库建表脚本
│   └── 01-schema.sql        # 21 张表，含完整索引
├── docs/                    # 项目文档
└── docker-compose.yml       # Docker 编排
```

## 核心设计

- **21 张数据库表**：用户权限 3 张、基础资料 6 张、业务单据 6 张、库存 5 张、系统配置 1 张，含完整外键与索引设计
- **无状态 JWT 认证**：Sa-Token + JWT 模式，无需 Redis 即可实现登录鉴权
- **自动编码系统**：各类单据/基础资料编码自动生成，保证唯一性
- **FIFO 出库策略**：先进先出批次扣减，支持指定批次出库
- **乐观锁并发控制**：防止高并发下库存超卖
- **AOP 操作审计**：关键写操作自动记入日志，按模块/日期审计追溯
- **出入库事务安全**：单据状态变更与库存更新在同一事务中，保证数据一致性
- **文件上传服务**：商品图片上传至服务器本地目录，通过 `/uploads/` 路径访问，Nginx 反向代理

## 关键业务流程

```
登录 → 商品管理 → 采购入库 → 库存增加 →
销售出库 → 库存扣减 (FIFO) → 安全库存预警 →
库存盘点 → 盈亏调整 → 库存流水追溯 →
库存调拨 → 调出扣减 → 调入增加
```

## License

MIT
