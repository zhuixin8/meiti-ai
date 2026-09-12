#!/usr/bin/env bash
set -Eeuo pipefail

EDGE_VERSION="${ALQQ_EDGE_VERSION:-1.1.5}"
INSTALL_DIR="${ALQQ_EDGE_INSTALL_DIR:-}"
MODE="${ALQQ_EDGE_MODE:-auto}"
COMMAND="install"
PURGE=0
KEEP_CACHE="${ALQQ_EDGE_KEEP_CACHE:-0}"
LOG_LINES=200
FOLLOW_LOGS=1
RELEASE_REPOSITORY="${ALQQ_EDGE_RELEASE_REPOSITORY:-zhuixin8/meiti-ai}"
CONTAINER_NAME="alqq-edge"
VOLUME_NAME="alqq-edge-data"
CLI_LINK="/usr/local/bin/alqq-edge"

usage() {
    cat <<'USAGE'
ALQQ 云执行节点安装器

用法:
  sudo bash install-edge.sh <命令> [选项]

常用命令:
  install       首次安装或重新部署节点
  upgrade       升级到 --version 指定版本
  status        查看容器、节点与引擎状态
  health        执行节点健康检查
  logs          查看节点日志，默认持续跟随
  restart       安全重启节点
  start|stop    启动或停止节点
  diagnose      输出脱敏诊断信息
  version       查看 Agent、镜像与引擎版本
  commands      显示安装后的快捷命令
  uninstall     卸载节点，默认保留凭据数据卷

选项:
  --version VERSION       安装版本，默认 1.1.5
  --mode auto|compose|docker
  --pairing-code CODE     首次安装配对码
  --node-name NAME        主站显示的节点名称
  --cloud-url URL         主站地址，默认 https://www.alqq.cn
  --install-dir PATH      配置目录
  --lines NUMBER          logs 显示行数，默认 200
  --no-follow             logs 输出后立即返回
  --keep-cache            安装成功后保留已验证的镜像归档
  --purge                 卸载时同时删除凭据数据卷（不可恢复）

安装完成后可直接运行: sudo alqq-edge status
USAGE
}

if [ $# -gt 0 ] && [[ "$1" != --* ]]; then COMMAND="$1"; shift; fi
while [ $# -gt 0 ]; do
    case "$1" in
        --version) EDGE_VERSION="$2"; shift 2 ;;
        --mode) MODE="$2"; shift 2 ;;
        --pairing-code) export ALQQ_PAIRING_CODE="$2"; shift 2 ;;
        --node-name) export ALQQ_NODE_NAME="$2"; shift 2 ;;
        --cloud-url) export ALQQ_CLOUD_URL="$2"; shift 2 ;;
        --install-dir) INSTALL_DIR="$2"; shift 2 ;;
        --lines) LOG_LINES="$2"; shift 2 ;;
        --no-follow) FOLLOW_LOGS=0; shift ;;
        --keep-cache) KEEP_CACHE=1; shift ;;
        --purge) PURGE=1; shift ;;
        -h|--help) usage; exit 0 ;;
        *) echo "未知参数: $1" >&2; usage; exit 2 ;;
    esac
done

case "$COMMAND" in doctor) COMMAND=diagnose ;; update) COMMAND=upgrade ;; esac
case "$COMMAND" in install|upgrade|status|health|logs|restart|start|stop|diagnose|version|commands|uninstall) ;; *) echo "未知命令: $COMMAND" >&2; exit 2 ;; esac
case "$MODE" in auto|compose|docker) ;; *) echo "--mode 只能是 auto、compose 或 docker" >&2; exit 2 ;; esac
if ! [[ "$LOG_LINES" =~ ^[1-9][0-9]*$ ]] || [ "$LOG_LINES" -gt 10000 ]; then
    echo "--lines 必须是 1 到 10000 之间的整数" >&2
    exit 2
fi

show_commands() {
    cat <<'COMMANDS'
ALQQ 云执行节点常用命令:
  sudo alqq-edge status                 查看节点状态
  sudo alqq-edge health                 检查健康接口
  sudo alqq-edge logs                   持续查看日志
  sudo alqq-edge logs --lines 500 --no-follow
  sudo alqq-edge restart                安全重启节点
  sudo alqq-edge stop                   停止领取和执行任务
  sudo alqq-edge start                  恢复运行
  sudo alqq-edge diagnose               输出脱敏诊断信息
  sudo alqq-edge version                查看版本
  sudo alqq-edge upgrade --version 1.1.5
  sudo alqq-edge uninstall              卸载但保留凭据
  sudo alqq-edge uninstall --purge      永久删除本机节点凭据
COMMANDS
}

if [ "$COMMAND" = commands ]; then show_commands; exit 0; fi

if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 root 运行，或在命令前加 sudo。" >&2
    exit 1
fi
if ! command -v docker >/dev/null 2>&1; then
    echo "未检测到 Docker Engine。请先按 Docker 官方文档安装 Docker，再重新运行本脚本。" >&2
    exit 1
fi

if [ -z "$INSTALL_DIR" ]; then
    SCRIPT_PATH="$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || printf '%s' "${BASH_SOURCE[0]}")"
    SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" >/dev/null 2>&1 && pwd -P)"
    if [ -f "$SCRIPT_DIR/.env" ] && [ -f "$SCRIPT_DIR/docker-compose.yml" ]; then
        INSTALL_DIR="$SCRIPT_DIR"
    elif [ -f /opt/alqq-edge/.env ]; then
        INSTALL_DIR=/opt/alqq-edge
    elif [ -d /www/server/panel ]; then
        INSTALL_DIR=/www/dk_project/dk_app/alqq-edge
    else
        INSTALL_DIR=/opt/alqq-edge
    fi
fi

compose_available() { docker compose version >/dev/null 2>&1; }
if [ "$MODE" = auto ]; then
    if compose_available; then MODE=compose; else MODE=docker; fi
fi
if [ "$MODE" = compose ] && ! compose_available; then
    echo "未安装 Docker Compose v2。可安装 Compose，或改用 --mode docker。" >&2
    exit 1
fi

read_existing_value() {
    local key="$1"
    [ -f "$INSTALL_DIR/.env" ] || return 0
    sed -n "s/^${key}=//p" "$INSTALL_DIR/.env" | tail -n 1
}

run_compose() {
    docker compose -f "$INSTALL_DIR/docker-compose.yml" --env-file "$INSTALL_DIR/.env" "$@"
}

health_json() {
    if ! docker inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
        echo "节点容器不存在" >&2
        return 1
    fi
    docker exec "$CONTAINER_NAME" node -e \
        "fetch('http://127.0.0.1:8787/healthz').then(async r=>{const body=await r.text();console.log(body);if(!r.ok)process.exit(1)}).catch(e=>{console.error(e.message);process.exit(1)})"
}

show_status() {
    docker ps -a --filter "name=^/${CONTAINER_NAME}$" --format 'table {{.Names}}\t{{.Status}}\t{{.Image}}'
    if docker inspect "$CONTAINER_NAME" >/dev/null 2>&1; then
        docker inspect --format '健康状态: {{if .State.Health}}{{.State.Health.Status}}{{else}}未配置{{end}} | 镜像: {{.Config.Image}}' "$CONTAINER_NAME"
        health_json 2>/dev/null || true
    fi
}

if [ "$COMMAND" = status ]; then show_status; exit 0; fi
if [ "$COMMAND" = health ]; then health_json; exit $?; fi
if [ "$COMMAND" = logs ]; then
    LOG_ARGS=(--tail "$LOG_LINES")
    if [ "$FOLLOW_LOGS" -eq 1 ]; then LOG_ARGS+=(-f); fi
    docker logs "${LOG_ARGS[@]}" "$CONTAINER_NAME"
    exit $?
fi
if [ "$COMMAND" = restart ]; then
    docker restart --time 90 "$CONTAINER_NAME" >/dev/null
    echo "节点已重启。"
    show_status
    exit 0
fi
if [ "$COMMAND" = start ]; then docker start "$CONTAINER_NAME" >/dev/null; echo "节点已启动。"; exit 0; fi
if [ "$COMMAND" = stop ]; then docker stop --time 90 "$CONTAINER_NAME" >/dev/null; echo "节点已停止。"; exit 0; fi
if [ "$COMMAND" = version ]; then
    docker inspect --format '镜像: {{.Config.Image}} | Agent: {{index .Config.Labels "com.alqq.version"}}' "$CONTAINER_NAME"
    health_json 2>/dev/null || true
    exit 0
fi
if [ "$COMMAND" = diagnose ]; then
    echo "=== 主机 ==="
    uname -a
    printf 'CPU: '; nproc 2>/dev/null || echo 未知
    if command -v free >/dev/null 2>&1; then free -h; fi
    df -h "$INSTALL_DIR" 2>/dev/null || df -h /
    echo "=== Docker ==="
    docker version
    if compose_available; then docker compose version; fi
    echo "=== 节点 ==="
    show_status
    echo "=== 最近日志 ==="
    docker logs --tail "$LOG_LINES" "$CONTAINER_NAME" 2>&1 || true
    echo "提示: 诊断信息不包含配对码和节点令牌，可复制给 ALQQ 技术支持。"
    exit 0
fi
if [ "$COMMAND" = uninstall ]; then
    if [ -f "$INSTALL_DIR/docker-compose.yml" ] && [ -f "$INSTALL_DIR/.env" ] && compose_available; then
        run_compose down --remove-orphans || true
    fi
    docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
    if [ "$PURGE" -eq 1 ]; then
        docker volume rm "$VOLUME_NAME"
        echo "已卸载节点并永久删除本地令牌/请求密钥数据卷。"
    else
        echo "已卸载节点；数据卷 ${VOLUME_NAME} 已保留，可用于恢复。"
    fi
    if [ -L "$CLI_LINK" ] && [ "$(readlink "$CLI_LINK")" = "$INSTALL_DIR/install-edge.sh" ]; then
        rm -f "$CLI_LINK"
    fi
    exit 0
fi

stage() { printf '\n[%s/8] %s\n' "$1" "$2"; }

stage 1 "检查 Linux 与 Docker 环境"

for command in curl sha256sum openssl gzip; do
    if ! command -v "$command" >/dev/null 2>&1; then
        echo "缺少 ${command}，请先通过系统包管理器安装。" >&2
        exit 1
    fi
done
if ! docker info >/dev/null 2>&1; then
    echo "Docker 服务未运行，或当前用户无法访问 Docker。" >&2
    exit 1
fi

case "$(uname -m)" in
    x86_64|amd64) RELEASE_ARCH="linux-amd64"; DOCKER_ARCH="amd64" ;;
    aarch64|arm64) RELEASE_ARCH="linux-arm64"; DOCKER_ARCH="arm64" ;;
    *) echo "不支持当前架构: $(uname -m)。支持 amd64 与 arm64。" >&2; exit 1 ;;
esac

RELEASE_BASE="https://github.com/${RELEASE_REPOSITORY}/releases/download/edge-v${EDGE_VERSION}"
IMAGE="alqq/edge-agent:${EDGE_VERSION}"
ARCHIVE="alqq-edge-agent-${EDGE_VERSION}-${RELEASE_ARCH}.tar.gz"
mkdir -p "$INSTALL_DIR"
chmod 700 "$INSTALL_DIR"
CACHE_DIR="${ALQQ_EDGE_CACHE_DIR:-$INSTALL_DIR/cache}"
mkdir -p "$CACHE_DIR"
chmod 700 "$CACHE_DIR"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

CPU_CORES="$(nproc 2>/dev/null || echo 0)"
MEMORY_MB="$(awk '/MemTotal:/ { printf "%d", $2 / 1024 }' /proc/meminfo 2>/dev/null || echo 0)"
FREE_KB="$(df -Pk "$INSTALL_DIR" | awk 'NR==2 {print $4}')"
if [ "${FREE_KB:-0}" -lt 3145728 ]; then
    echo "可用磁盘不足 3 GB，无法安全安装云执行节点。" >&2
    exit 1
fi
if [ "${CPU_CORES:-0}" -lt 2 ]; then echo "警告: 当前不足 2 核 CPU，发布速度和稳定性可能受影响。" >&2; fi
if [ "${MEMORY_MB:-0}" -lt 3800 ]; then echo "警告: 当前内存不足建议的 4 GB，请减少节点并发。" >&2; fi
echo "架构 ${RELEASE_ARCH}，CPU ${CPU_CORES} 核，内存 ${MEMORY_MB} MB，可用磁盘 $((FREE_KB / 1024)) MB。"

release_bases=()
if [ -n "${ALQQ_EDGE_RELEASE_BASES:-}" ]; then
    IFS=',' read -r -a configured_bases <<< "$ALQQ_EDGE_RELEASE_BASES"
    for base in "${configured_bases[@]}"; do
        base="${base%/}"
        [ -n "$base" ] && release_bases+=("$base")
    done
fi
release_bases+=("$RELEASE_BASE")

download_release_file() {
    local relative="$1"
    local destination="$2"
    local resume="${3:-0}"
    local base
    local result=1
    for base in "${release_bases[@]}"; do
        echo "下载源: ${base}"
        # 兼容 Ubuntu 20.04 / Debian 旧版 curl；不依赖 7.71 才加入的 --retry-all-errors。
        CURL_ARGS=(-fL --retry 4 --retry-connrefused --connect-timeout 15 --speed-time 30 --speed-limit 10240 --progress-bar)
        if [ "$resume" -eq 1 ] && [ -s "$destination" ]; then CURL_ARGS+=(--continue-at -); fi
        if curl "${CURL_ARGS[@]}" "${base}/${relative}" -o "$destination"; then
            result=0
            break
        fi
        echo "当前下载源失败，尝试下一个来源。" >&2
    done
    return "$result"
}

cat > "$TMP_DIR/release-public.pem" <<'PUBLIC_KEY'
-----BEGIN PUBLIC KEY-----
MCowBQYDK2VwAyEA5JC/aCk6w0blkFFEVo/QBSApIkuEXFyDI/HlvkTkTgU=
-----END PUBLIC KEY-----
PUBLIC_KEY

stage 2 "下载并验证安装器"
# 保存一份已验证的安装器，供后续 status/diagnose/upgrade 使用。
download_release_file install-edge.sh "$TMP_DIR/install-edge.sh"
download_release_file install-edge.sh.sig "$TMP_DIR/install-edge.sh.sig"
openssl pkeyutl -verify -pubin -inkey "$TMP_DIR/release-public.pem" -rawin \
    -in "$TMP_DIR/install-edge.sh" -sigfile "$TMP_DIR/install-edge.sh.sig" >/dev/null
install -m 700 "$TMP_DIR/install-edge.sh" "$INSTALL_DIR/install-edge.sh"

stage 3 "下载节点镜像（支持断点续传）"
ARCHIVE_CACHE="$CACHE_DIR/$ARCHIVE"
ARCHIVE_PART="$ARCHIVE_CACHE.part"
if [ ! -s "$ARCHIVE_CACHE" ]; then
    download_release_file "$ARCHIVE" "$ARCHIVE_PART" 1
    mv -f "$ARCHIVE_PART" "$ARCHIVE_CACHE"
else
    echo "复用本机缓存: $ARCHIVE_CACHE"
fi
download_release_file "$ARCHIVE.sha256" "$TMP_DIR/$ARCHIVE.sha256"
download_release_file "$ARCHIVE.sig" "$TMP_DIR/$ARCHIVE.sig"

stage 4 "校验 SHA-256 与 Ed25519 发布签名"
(
    cd "$CACHE_DIR"
    sha256sum -c "$TMP_DIR/$ARCHIVE.sha256"
) || {
    rm -f "$ARCHIVE_CACHE"
    echo "镜像校验失败，已删除损坏缓存，请重新执行安装命令。" >&2
    exit 1
}
openssl pkeyutl -verify -pubin -inkey "$TMP_DIR/release-public.pem" -rawin \
    -in "$ARCHIVE_CACHE" -sigfile "$TMP_DIR/$ARCHIVE.sig" >/dev/null || {
    rm -f "$ARCHIVE_CACHE"
    echo "镜像发布签名无效，已删除缓存。" >&2
    exit 1
}
echo "Release Ed25519 签名验证通过。"

stage 5 "导入并检查节点镜像"
gzip -dc "$ARCHIVE_CACHE" | docker load >/dev/null
docker image inspect "$IMAGE" >/dev/null
IMAGE_ARCH="$(docker image inspect --format '{{.Architecture}}' "$IMAGE")"
if [ "$IMAGE_ARCH" != "$DOCKER_ARCH" ]; then
    echo "镜像架构错误: 当前需要 ${DOCKER_ARCH}，实际为 ${IMAGE_ARCH}。" >&2
    exit 1
fi

docker volume inspect "$VOLUME_NAME" >/dev/null 2>&1 || docker volume create "$VOLUME_NAME" >/dev/null
# v1.1.1 及更早版本以 root 写入数据卷；升级时只在一次性迁移容器内修正所有权，
# 正式节点仍以固定 uid/gid 10001 非 root 运行。
docker run --rm --user 0:0 --entrypoint sh -v "$VOLUME_NAME:/data" "$IMAGE" \
    -lc 'chown -R 10001:10001 /data' >/dev/null
EXISTING_CLOUD_URL="$(read_existing_value ALQQ_CLOUD_URL)"
EXISTING_NODE_NAME="$(read_existing_value ALQQ_NODE_NAME)"
EXISTING_CONCURRENCY="$(read_existing_value ALQQ_EXECUTOR_CONCURRENCY)"
EXISTING_HEALTH_PORT="$(read_existing_value ALQQ_HEALTH_PORT)"
EXISTING_TIMEZONE="$(read_existing_value TZ)"
PAIRING_CODE="${ALQQ_PAIRING_CODE:-}"

if ! docker run --rm --entrypoint sh -v "$VOLUME_NAME:/data" "$IMAGE" -lc 'test -s /data/edge-token' >/dev/null 2>&1; then
    if [ -z "$PAIRING_CODE" ] && [ -r /dev/tty ]; then
        printf '请输入主站生成的 15 分钟一次性配对码: ' > /dev/tty
        IFS= read -r PAIRING_CODE < /dev/tty
    fi
    if [ -z "$PAIRING_CODE" ]; then echo "首次安装必须提供配对码。" >&2; exit 1; fi
fi

sanitize_line() { printf '%s' "$1" | tr '\r\n' '  '; }
NODE_NAME="$(sanitize_line "${ALQQ_NODE_NAME:-${EXISTING_NODE_NAME:-Linux Docker 节点}}")"
NODE_HOSTNAME="$(sanitize_line "${ALQQ_NODE_HOSTNAME:-$(hostname -f 2>/dev/null || hostname)}")"
umask 077
cat > "$INSTALL_DIR/.env" <<EOF
ALQQ_CLOUD_URL=${ALQQ_CLOUD_URL:-${EXISTING_CLOUD_URL:-https://www.alqq.cn}}
ALQQ_PAIRING_CODE=${PAIRING_CODE}
ALQQ_NODE_NAME=${NODE_NAME}
ALQQ_NODE_HOSTNAME=${NODE_HOSTNAME}
ALQQ_EXECUTOR_CONCURRENCY=${ALQQ_EXECUTOR_CONCURRENCY:-${EXISTING_CONCURRENCY:-1}}
ALQQ_HEALTH_PORT=${ALQQ_HEALTH_PORT:-${EXISTING_HEALTH_PORT:-8787}}
ALQQ_EDGE_VERSION=${EDGE_VERSION}
ALQQ_EDGE_AUTO_UPDATE=${ALQQ_EDGE_AUTO_UPDATE:-1}
ALQQ_EDGE_UPDATE_CHANNEL=${ALQQ_EDGE_UPDATE_CHANNEL:-stable}
TZ=${TZ:-${EXISTING_TIMEZONE:-Asia/Shanghai}}
EOF

stage 6 "写入最小权限运行配置"

cat > "$INSTALL_DIR/docker-compose.yml" <<'COMPOSE'
services:
    alqq-edge:
        image: alqq/edge-agent:${ALQQ_EDGE_VERSION}
        pull_policy: never
        container_name: alqq-edge
        restart: unless-stopped
        env_file: [.env]
        ports: ["127.0.0.1:${ALQQ_HEALTH_PORT:-8787}:8787"]
        volumes: ["alqq-edge-data:/data"]
        shm_size: 1gb
        init: true
        pids_limit: 512
        stop_grace_period: 90s
        read_only: true
        tmpfs:
            - /tmp:size=512m,mode=1777
            - /run:size=16m,mode=755
        security_opt: ["no-new-privileges:true"]
        cap_drop: [ALL]
        labels:
            createdBy: "bt_apps"
            com.alqq.component: "edge-agent"
            com.alqq.version: "${ALQQ_EDGE_VERSION}"
volumes:
    alqq-edge-data:
        name: alqq-edge-data
        external: true
COMPOSE

start_docker_mode() {
    docker run -d --name "$CONTAINER_NAME" --restart unless-stopped --init \
        --env-file "$INSTALL_DIR/.env" --read-only \
        --tmpfs /tmp:size=512m,mode=1777 --tmpfs /run:size=16m,mode=755 \
        --security-opt no-new-privileges:true --cap-drop ALL --shm-size 1g --pids-limit 512 --stop-timeout 90 \
        -p "127.0.0.1:${ALQQ_HEALTH_PORT:-${EXISTING_HEALTH_PORT:-8787}}:8787" \
        -v "$VOLUME_NAME:/data" --label createdBy=bt_apps \
        --label com.alqq.component=edge-agent --label "com.alqq.version=${EDGE_VERSION}" "$IMAGE" >/dev/null
}

docker rm -f "$CONTAINER_NAME" >/dev/null 2>&1 || true
stage 7 "启动云执行节点容器"
if [ "$MODE" = compose ]; then run_compose up -d --force-recreate; else start_docker_mode; fi
printf '%s\n' "$MODE" > "$INSTALL_DIR/.install-mode"

stage 8 "等待主站配对与健康检查"
for _ in $(seq 1 60); do
    HEALTH="$(docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{end}}' "$CONTAINER_NAME" 2>/dev/null || true)"
    if docker exec "$CONTAINER_NAME" test -s /data/edge-token >/dev/null 2>&1 && [ "$HEALTH" = healthy ]; then break; fi
    sleep 2
done
if ! docker exec "$CONTAINER_NAME" test -s /data/edge-token >/dev/null 2>&1; then
    echo "节点未完成配对，最近日志:" >&2
    docker logs --tail 80 "$CONTAINER_NAME" >&2 || true
    exit 1
fi

sed -i 's/^ALQQ_PAIRING_CODE=.*/ALQQ_PAIRING_CODE=/' "$INSTALL_DIR/.env"
if [ "$MODE" = compose ]; then
    run_compose up -d --force-recreate >/dev/null
else
    docker rm -f "$CONTAINER_NAME" >/dev/null
    start_docker_mode
fi

if [ ! -e "$CLI_LINK" ] || [ -L "$CLI_LINK" ]; then
    ln -sfn "$INSTALL_DIR/install-edge.sh" "$CLI_LINK"
else
    echo "提示: ${CLI_LINK} 已存在且不是符号链接，未覆盖；仍可使用完整脚本路径。" >&2
fi
if [ "$KEEP_CACHE" != 1 ]; then rm -f "$ARCHIVE_CACHE"; fi

echo "ALQQ 云执行节点 v${EDGE_VERSION} 已安装（${MODE}/${RELEASE_ARCH}）。"
echo "主站管理: https://www.alqq.cn/app/execution-nodes"
echo "节点状态: sudo alqq-edge status"
echo "查看日志: sudo alqq-edge logs"
echo "诊断命令: sudo alqq-edge diagnose"
echo "全部命令: sudo alqq-edge commands"
