<div align="center">
<br>

<img width="200" src="./screenshots/Sub-Store.png" alt="luci-app-substore">

<br><br>

<h2 align="center">SubStore</h2>

</div>

<p align="center">
OpenWrt 上的 Sub-Store LuCI 管理插件，提供图形化界面管理订阅服务。
</p>

---

## 目录

- [系统要求](#系统要求)
- [安装方法](#安装方法)
- [配置文件](#配置文件)
- [License](#license)

---

## 系统要求

| 项目 | 要求 |
|---|---|
| OpenWrt | 支持新版 LuCI JS 框架 |
| 包管理 | opkg 或 apk |
| 依赖 | node、unzip |
| 内存 | 建议 128MB 以上 |

---

## 安装方法

### 一键安装（推荐）

SSH 登录路由器执行：

    wget -O - https://github.com/XiaoHaiSly/OpenWrt-SubStore/raw/refs/heads/main/scripts/install.sh | ash

---

### 手动安装

#### OpenWrt 24.10 及以前（opkg）

    wget -O /tmp/substore-ipk.pub https://substore-openwrt.pages.dev/substore-ipk.pub

    opkg-key add /tmp/substore-ipk.pub

    echo "src/gz substore https://substore-openwrt.pages.dev/openwrt-24.10/all" \
    > /etc/opkg/substore.conf

    opkg update

    opkg install luci-app-substore

#### OpenWrt 25.12 及以后（apk）

    wget -O /etc/apk/keys/substore-apk.pem \
    https://substore-openwrt.pages.dev/substore-apk.pem

    mkdir -p /etc/apk/repositories.d

    echo "https://substore-openwrt.pages.dev/openwrt-25.12/all/packages.adb" \
    > /etc/apk/repositories.d/substore.list

    apk update

    apk add luci-app-substore

---

## 配置文件

配置文件：

    /etc/config/substore

修改配置后重启服务即可生效。

---

## License

GPL-3.0
