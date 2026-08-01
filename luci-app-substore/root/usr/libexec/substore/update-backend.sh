#!/bin/sh
set -e

SOURCE="$1"
if [ "$SOURCE" != "proxy" ] && [ "$SOURCE" != "official" ]; then
	echo "FAIL: 参数必须是 proxy 或 official（实际收到: $SOURCE）" >&2
	exit 1
fi

MV=$(command -v mv) || MV=""
RM=$(command -v rm) || RM=""
WGET=$(command -v wget) || WGET=""
BUNDLE=/usr/libexec/substore/sub-store.bundle.js
TMP="$BUNDLE.tmp"
PROXY_PREFIX=$(uci -q get substore.config.download_proxy) || PROXY_PREFIX=""
PROXY_PREFIX="${PROXY_PREFIX%/}"
[ -n "$PROXY_PREFIX" ] && PROXY_PREFIX="$PROXY_PREFIX/"
GITHUB_TOKEN=$(uci -q get substore.config.github_token) || GITHUB_TOKEN=""
OFFICIAL_URL="https://github.com/sub-store-org/Sub-Store/releases/latest/download/sub-store.bundle.js"
PROXY_URL="$PROXY_PREFIX$OFFICIAL_URL"
GITHUB_API_URL="https://api.github.com/repos/sub-store-org/Sub-Store/releases/latest"
PROXY_API_URL="$PROXY_PREFIX$GITHUB_API_URL"
VERSION_FILE="/usr/libexec/substore/backend.version"

WGET_API_OPTS="--timeout=8 --tries=1"
WGET_DL_OPTS="--timeout=15 --tries=2 --waitretry=3"

if [ -z "$WGET" ]; then
	echo "FAIL: wget-ssl 命令未找到" >&2
	exit 1
fi

if [ "$SOURCE" = "proxy" ] && [ -z "$PROXY_PREFIX" ]; then
	echo "DOWNLOAD_FAILED: 未配置更新加速代理"
	exit 0
fi

case "$SOURCE" in
	proxy) URL="$PROXY_URL" ;;
	official) URL="$OFFICIAL_URL" ;;
esac

CURRENT_VERSION=""
[ -f "$VERSION_FILE" ] && CURRENT_VERSION=$(cat "$VERSION_FILE" 2>/dev/null | tr -d '\r\n')

# 校验 tag 是否形如合法版本号（长度、字符集限制），避免把异常/垃圾内容当版本号写入
looks_like_version_tag() {
	t="$1"
	[ -z "$t" ] && return 1
	[ "${#t}" -gt 40 ] && return 1
	printf '%s' "$t" | grep -Eq '^[A-Za-z0-9._+-]+$' || return 1
	return 0
}

# 通过 wget-ssl 请求 GitHub Release API 并提取 tag_name 字段
fetch_tag_api() {
	api_url="$1"
	[ -z "$api_url" ] && return 1
	auth_header=""
	[ -n "$GITHUB_TOKEN" ] && auth_header="--header=Authorization: token $GITHUB_TOKEN"
	"$WGET" $WGET_API_OPTS $auth_header -qO- "$api_url" 2>/dev/null \
		| sed -n 's/.*"tag_name" *: *"\([^"]*\)".*/\1/p' | head -n1
}

# 按 SOURCE 决定优先查询顺序（proxy 源优先查代理 API，official 源优先查直连 API），
# 任一查询失败自动尝试另一个，尽量拿到准确版本号
get_latest_tag() {
	if [ "$SOURCE" = "proxy" ]; then
		first_api="$PROXY_API_URL"; second_api="$GITHUB_API_URL"
	else
		first_api="$GITHUB_API_URL"; second_api="$PROXY_API_URL"
	fi
	for api_url in "$first_api" "$second_api"; do
		[ -z "$api_url" ] && continue
		tag=$(fetch_tag_api "$api_url")
		if looks_like_version_tag "$tag"; then
			echo "$tag"
			return 0
		fi
	done
	return 1
}

LATEST_TAG=$(get_latest_tag || true)

if [ -n "$LATEST_TAG" ] && [ -n "$CURRENT_VERSION" ] && [ "$LATEST_TAG" = "$CURRENT_VERSION" ]; then
	echo "ALREADY_LATEST:$LATEST_TAG"
	exit 0
fi

"$RM" -f "$TMP"
if ! "$WGET" $WGET_DL_OPTS -q -O "$TMP" "$URL"; then
	"$RM" -f "$TMP"
	echo "DOWNLOAD_FAILED: 下载失败（wget 请求出错，可能是网络问题或地址不可达）"
	exit 0
fi

if [ ! -s "$TMP" ]; then
	"$RM" -f "$TMP"
	echo "DOWNLOAD_FAILED: 下载后文件为空"
	exit 0
fi

if head -c 200 "$TMP" | grep -qi '<html\|<!DOCTYPE'; then
	"$RM" -f "$TMP"
	echo "DOWNLOAD_FAILED: 返回内容像是 HTML 错误页，不是 js bundle"
	exit 0
fi

"$MV" -f "$TMP" "$BUNDLE"

/etc/init.d/substore restart

sleep 2

if ! pgrep -f "$BUNDLE" >/dev/null; then
	echo "FAIL: 重启后未检测到进程运行" >&2
	exit 1
fi

if [ -n "$LATEST_TAG" ]; then
	printf '%s' "$LATEST_TAG" > "$VERSION_FILE"
else
	FINAL_TAG=$(get_latest_tag || true)
	if [ -n "$FINAL_TAG" ]; then
		printf '%s' "$FINAL_TAG" > "$VERSION_FILE"
	else
		echo "本次没能确定版本号，保留原有记录" >&2
	fi
fi

echo "OK"
exit 0
