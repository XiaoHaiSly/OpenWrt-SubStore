<div align="center">
<br>
<!--
  === Logo/截图 ===
-->
<img width="200" src="./screenshots/Sub-Store.png" alt="luci-app-substore">
<br>
<br>
<h2 align="center">SubStore</h2>
</div>

<p align="center" color="#6a737d">
在 OpenWrt 上一键安装 <a href="https://github.com/sub-store-org/Sub-Store">Sub-Store</a> 高级订阅管器 
</p>

---

## 系统要求

| 项目 | 要求 |
|---|---|
| OpenWrt 版本 |依赖新版 LuCI JS 前端框架 `ui.js`/`view.extend`|
| 构架支持 | LuCI 部分为纯 Lua/JS（arch:all），后端依赖 Node.js，跟随 OpenWrt 官方 node 软件包支持的架构范围 |
| 依赖软件包 | `node`、`unzip` |
| 存储空间 | 建议预留 40MB 以上可用空间（node 运行时 + 后端 bundle + 前端静态资源） |
| 内存 | 256MB 及以上机型可正常运行，跑大量订阅/脚本时建议 512MB 以上 |

---

## 安装方法

### 方式一：一键脚本（推荐）

SSH 登录路由器执行：

```sh
wget -O - https://github.com/XiaoHaiSly/OpenWrt-SubStore/raw/refs/heads/main/scripts/install.sh | ash
```



### 方式二：手动添加软件源

**OpenWrt 24.10 及更早（opkg）：**

```sh
wget -O /tmp/substore-ipk.pub https://substore-openwrt.pages.dev/substore-ipk.pub
opkg-key add /tmp/substore-ipk.pub
echo "src/gz substore https://substore-openwrt.pages.dev/openwrt-24.10/all" > /etc/opkg/substore.conf
opkg update
opkg install luci-app-substore
```

**OpenWrt 25.12 及以后（apk）：**

```sh
wget -O /etc/apk/keys/substore-apk.pem https://substore-openwrt.pages.dev/substore-apk.pem
mkdir -p /etc/apk/repositories.d
echo "https://substore-openwrt.pages.dev/openwrt-25.12/all/packages.adb" > /etc/apk/repositories.d/substore.list
apk update
apk add luci-app-substore
```

### 方式三：LuCI 网页手动上传 ipk/apk

在 Releases 下载 ipk/apk 文件，LuCI → 系统 → 软件包 → 上传安装。

---

## 配置项详解

配置文件位于 `/etc/config/substore`，对应 UCI section `config`：

| 字段 | 默认值 | 说明 |
|---|---|---|
| `enabled` | `0` | 是否启用服务 |
| `frontend_port` | `3001` | 服务监听端口（前后端合并单端口模式） |
| `frontend_host` | `::` | 监听地址：`::` 同时监听 IPv4/IPv6，`0.0.0.0` 仅 IPv4，`127.0.0.1` 仅本机 |
| `frontend_backend_path` | `/sub-store-api` | 后端 API 路径前缀 |
| `data_dir` | `/etc/sub-store` | 数据文件存放目录 |
| `backend_custom_name` | `OpenWrt` | 前端界面显示的后端实例名称 |
| `backend_custom_icon` | 空 | 前端界面显示的后端图标 URL |
| `backend_sync_cron` | 空 | 订阅同步到 Gist 的 cron 定时 |
| `backend_upload_cron` | 空 | 数据备份到 Gist 的 cron 定时 |
| `backend_download_cron` | 空 | 从 Gist 恢复数据的 cron 定时 |
| `produce_cron` | 空 | 订阅/组合预处理定时，格式：`cron表达式,类型,名称`，类型为 `sub` 或 `col`，多条用 `;` 分隔 |
| `push_service` | 空 | 推送通知服务 URL，支持 `[推送标题]`/`[推送内容]` 占位符 |
| `cors_allowed_origins` | `*` | 允许访问后端 API 的浏览器来源 |
| `backend_default_proxy` | 空 | 抓取订阅时使用的默认代理，支持 `http://`/`https://`/`socks5://` |
| `max_header_size` | `32768` | 最大请求头大小（字节） |
| `body_json_limit` | `1mb` | 请求体大小限制 |
| `x_powered_by` | 空 | 自定义 `X-Powered-By` 响应头 |
| `data_url` | 空 | 启动时拉取恢复数据的远程地址 |
| `data_url_post` | 空 | 拉取数据后执行的 JS 表达式 |

---

## 从源码构建

需要 OpenWrt SDK 或完整源码树：

```sh
git clone https://github.com/XiaoHaiSly/OpenWrt-SubStore.git package/luci-app-substore
cd <openwrt源码目录>
make menuconfig   # LuCI -> Applications -> luci-app-substore 打勾
make package/luci-app-substore/compile V=s
```

构建过程会联网下载 Sub-Store 官方 Release 的后端 bundle 和前端 dist，并通过 GitHub API 查询最新版本号，请确保编译环境能访问 GitHub（`github.com` 和 `api.github.com`）。

---

## License

GPL-3.0
