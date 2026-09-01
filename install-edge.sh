#!/usr/bin/env bash
set -Eeuo pipefail

EDGE_VERSION="${ALQQ_EDGE_VERSION:-1.0.0}"
INSTALL_DIR="${ALQQ_EDGE_INSTALL_DIR:-/opt/alqq-edge}"
RELEASE_BASE="https://github.com/zhuixin8/meiti-ai/releases/download/edge-v${EDGE_VERSION}"
ARCHIVE="alqq-edge-agent-${EDGE_VERSION}.tar.gz"
IMAGE="alqq/edge-agent:${EDGE_VERSION}"

if [ "$(id -u)" -ne 0 ]; then
    echo "请使用 root 运行，或在命令前加 sudo。" >&2
    exit 1
fi
if ! command -v docker >/dev/null 2>&1; then
    echo "未检测到 Docker，请先在宝塔面板安装 Docker 管理器。" >&2
    exit 1
fi
if ! docker compose version >/dev/null 2>&1; then
    echo "未检测到 Docker Compose v2，请先在宝塔面板安装或升级 Docker。" >&2
    exit 1
fi
case "$(uname -m)" in
    x86_64|amd64) ;;
    *)
        echo "当前版本仅支持 x86_64/amd64 Linux 服务器。" >&2
        exit 1
        ;;
esac

mkdir -p "$INSTALL_DIR"
chmod 700 "$INSTALL_DIR"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT

echo "正在下载 ALQQ Linux 执行节点 v${EDGE_VERSION}..."
curl -fL --retry 3 --connect-timeout 15 \
    "$RELEASE_BASE/$ARCHIVE" -o "$TMP_DIR/$ARCHIVE"
curl -fL --retry 3 --connect-timeout 15 \
    "$RELEASE_BASE/$ARCHIVE.sha256" -o "$TMP_DIR/$ARCHIVE.sha256"
(
    cd "$TMP_DIR"
    sha256sum -c "$ARCHIVE.sha256"
)
gzip -dc "$TMP_DIR/$ARCHIVE" | docker load >/dev/null
docker image inspect "$IMAGE" >/dev/null

cat > "$INSTALL_DIR/docker-compose.yml" <<'COMPOSE'
services:
    alqq-edge:
        image: alqq/edge-agent:${ALQQ_EDGE_VERSION:-1.0.0}
        container_name: alqq-edge
        restart: unless-stopped
        env_file:
            - .env
        environment:
            TZ: Asia/Shanghai
        volumes:
            - alqq-edge-data:/data
        ports:
            - "127.0.0.1:${ALQQ_HEALTH_PORT:-8787}:8787"
        shm_size: 1gb
        security_opt:
            - no-new-privileges:true
        cap_drop:
            - ALL

volumes:
    alqq-edge-data:
        name: alqq-edge-data
        external: true
COMPOSE

PAIRING_CODE="${ALQQ_PAIRING_CODE:-}"
if ! docker run --rm --entrypoint sh -v alqq-edge-data:/data "$IMAGE" \
    -lc 'test -s /data/edge-token' >/dev/null 2>&1; then
    if [ -z "$PAIRING_CODE" ] && [ -r /dev/tty ]; then
        printf '请输入主站“自动化 → 执行节点”生成的配对码: ' > /dev/tty
        IFS= read -r PAIRING_CODE < /dev/tty
    fi
    if [ -z "$PAIRING_CODE" ]; then
        echo "首次安装必须提供 ALQQ_PAIRING_CODE。" >&2
        exit 1
    fi
fi

umask 077
cat > "$INSTALL_DIR/.env" <<EOF
ALQQ_CLOUD_URL=${ALQQ_CLOUD_URL:-https://www.alqq.cn}
ALQQ_PAIRING_CODE=${PAIRING_CODE}
ALQQ_NODE_NAME=${ALQQ_NODE_NAME:-宝塔 Docker 节点}
ALQQ_EXECUTOR_CONCURRENCY=${ALQQ_EXECUTOR_CONCURRENCY:-1}
ALQQ_HEALTH_PORT=${ALQQ_HEALTH_PORT:-8787}
ALQQ_EDGE_VERSION=${EDGE_VERSION}
EOF

docker compose -f "$INSTALL_DIR/docker-compose.yml" --env-file "$INSTALL_DIR/.env" up -d

for _ in $(seq 1 60); do
    if docker exec alqq-edge test -s /data/edge-token >/dev/null 2>&1 \
        && docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{end}}' alqq-edge 2>/dev/null | grep -qx healthy; then
        break
    fi
    sleep 2
done

if ! docker exec alqq-edge test -s /data/edge-token >/dev/null 2>&1; then
    echo "节点未能完成配对，请检查配对码和网络。最近日志如下:" >&2
    docker logs --tail 50 alqq-edge >&2 || true
    exit 1
fi

# 配对码只使用一次。配对成功后立即从持久配置及容器环境中移除。
sed -i 's/^ALQQ_PAIRING_CODE=.*/ALQQ_PAIRING_CODE=/' "$INSTALL_DIR/.env"
docker compose -f "$INSTALL_DIR/docker-compose.yml" --env-file "$INSTALL_DIR/.env" up -d --force-recreate >/dev/null

for _ in $(seq 1 30); do
    if docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{end}}' alqq-edge 2>/dev/null | grep -qx healthy; then
        break
    fi
    sleep 2
done
if ! docker inspect --format '{{if .State.Health}}{{.State.Health.Status}}{{end}}' alqq-edge 2>/dev/null | grep -qx healthy; then
    echo "节点已配对，但重启后的健康检查未通过。最近日志如下:" >&2
    docker logs --tail 50 alqq-edge >&2 || true
    exit 1
fi

echo "ALQQ Linux 执行节点已安装并完成配对。"
echo "管理入口: https://www.alqq.cn/app/execution-nodes"
echo "本机健康检查: curl http://127.0.0.1:${ALQQ_HEALTH_PORT:-8787}/healthz"
